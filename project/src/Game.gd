extends Node
class_name Game

signal round_started(Game)

enum GameState {
	MENU,
	PREPARE,
	PLAYING,
	DONE
}

export(int) var round_duration := 30
export(float) var paper_fly_duration := 1.5

var _state = GameState.MENU

const BEAN_GAME := {
	"name": "Beans",
	"data": [
		{
			"food": preload("res://src/Food/Bean/GreenBean.tscn"),
			"label": "Snap the Beans!",
			"song": preload("res://assets/ost/beans.ogg"),
		}
	]
}

const TOMATO_GAME := {
	"name": "Tomatoes",
	"data": [
		{
			"food": preload("res://src/Food/Tomato/PeelableTomato.tscn"),
			"label": "Peel the Tomatoes!",
			"song": preload("res://assets/ost/tomato_peeling.ogg")
		},
		{
			"food": preload("res://src/Food/Tomato/DiceableTomato.tscn"),
			"label": "Dice the Tomatoes!",
			"song": preload("res://assets/ost/tomato_chopping.ogg")
		},
	]
}

const CARROT_GAME := {
	"name": "Carrots",
	"data": [
		{
			"food": preload("res://src/Food/Carrot/CleanableCarrot.tscn"),
			"label": "Wash the Carrots!",
			"song": preload("res://assets/ost/carrot_washing.ogg"),
		},
		{
			"food": preload("res://src/Food/Carrot/PeelableCarrot.tscn"),
			"label": "Peel the Carrots!",
			"song": preload("res://assets/ost/carrot_peeling.ogg")
		},
		{
			"food": preload("res://src/Food/Carrot/ChoppableCarrot.tscn"),
			"label": "Cut the Carrots!",
			"song": preload("res://assets/ost/carrot_chopping.ogg")
		},
	]
}

const END_SONG := preload("res://assets/ost/ending.ogg")

onready var _workstations := []
onready var _tween_pool : TweenPool = $TweenPool
onready var _tray : Tray = $Tray
onready var _timer : Timer = $Timer
onready var _ui_timer : GameTimer = $Interface/GameTimer
onready var _GameOverScene := preload("res://src/UI/GameOver.tscn")

# The selected game
var _game_config : Dictionary

# The round of the game
var _round : int = 0

# Number of fruits completed
var _completed := 0


func _ready():
	_workstations = $Workstations.get_children()
	
	
func _start_round():
	_state = GameState.PREPARE
	$Interstitial.update_label(_get_this_round_data()["label"])
	$Interstitial.z_index = _completed + 1 # Force on top of food pile
	$AnimationPlayer.play("InterstitialFlyBy")
	
	
func _on_interstitialflyby_finished()->void:
	_state = GameState.PLAYING
	for workstation in _workstations:
		_add_food_to(workstation)
	_timer.start(round_duration)
	Soundtrack.play_song(_get_this_round_data()["song"])
	emit_signal("round_started", self)


func _get_this_round_data() -> Dictionary:
	return _game_config["data"][_round]

	
func _process(_delta:float):
	if _state==GameState.PLAYING:
		_ui_timer.update_time_remaining(_timer.time_left)
	else:
		_ui_timer.update_time_remaining(float(round_duration))


func _input(event):
	if event.is_action_pressed("engage_warp_speed"):
		_engage_warp_speed()

	
func _add_food_to(workstation:Node2D):
	# I noticed a strange, hard-to-trace bug where this can be called
	# after a round is over. I think it's related to the timing of
	# chopping: the chop animation finishes, _then_ the thing is marked
	# as done. So, we need to check to make sure we're still playing
	# before we add food to a workstation.
	if _state==GameState.PLAYING:
		var tween = _tween_pool.create()
		var source = workstation.spawn_point.get_global_transform().origin
		var destination = workstation.get_global_transform().origin
		var food = _get_this_round_data()["food"].instance()
		food.position = source
		food.rotation_degrees = rand_range(1,360)
		$Food.add_child(food)
		tween.interpolate_property(food, "position", source, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		food.connect("processed", self, "_on_food_processed", [workstation])


func _on_food_processed(_food:Food, good_parts:Array, scrap:Array, workstation):
	# Track completion and adjust Z so the latest is on top
	_completed = _completed + 1

	# Reparent the good parts and scrap to the game's Food node
	for piece in good_parts + scrap:
		piece.z_index = _completed
		var old_transform = piece.global_transform
		piece.get_parent().remove_child(piece)
		$Food.add_child(piece)
		piece.global_transform = old_transform
	
	# Fly the food to the tray
	for piece in good_parts:
		var destination = _tray.get_global_transform().xform(_tray.get_food_target())
		_send_food_to(piece, destination)
		
	# Fly the scrap to the scrap point
	for piece in scrap:
		var destination = workstation.get_global_transform().xform(workstation.get_scrap_point())
		_send_food_to(piece, destination)
	
	# Add a new food
	_add_food_to(workstation)


func _send_food_to(food:Sprite, destination:Vector2)->void:
	# Tween position
	var tween = _tween_pool.create()
	tween.interpolate_property(food, "position", null, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	# Tween rotation
	var rot_tween = _tween_pool.create()
	var rot_current = food.rotation
	var rot_target = rand_range(rot_current-3.14/4,rot_current+3.14/4)
	rot_tween.interpolate_property(food, "rotation", null, rot_target, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	rot_tween.start()


func _on_Timer_timeout():
	# Prevent further interaction with the food on the table
	for food in $Food.get_children():
		# Some children are Food, some are sprite parts
		if food is Food:
			(food as Food).enabled = false
		
	# Advance the round
	_round += 1
	
	# If the game is over, set up and fly in the GameOver scene
	if _round == _game_config["data"].size():
		_state = GameState.DONE
		var game_over_scene : GameOver = _GameOverScene.instance()
		game_over_scene.number_completed = _completed
		game_over_scene.food_name = _game_config["name"]
		game_over_scene.z_index = _completed  # Force on top of food pile
		add_child(game_over_scene)
		game_over_scene.position = Vector2(0,-game_over_scene.texture.get_height())
		var tween : Tween = _tween_pool.create()
		tween.interpolate_property(game_over_scene, "position", null, Vector2.ZERO, paper_fly_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		Soundtrack.play_song(END_SONG)
		
	# Otherwise start the next round
	else:
		_start_round()


func _on_MainMenu_game_selected(selection):
	match selection:
		"carrot":
			_game_config = CARROT_GAME
		"bean":
			_game_config = BEAN_GAME
		"tomato":
			_game_config = TOMATO_GAME
		_:
			print("UNEXPECTED GAME SELECTION: %s" % selection)
	var tween : Tween = _tween_pool.create()
	tween.interpolate_property($MainMenu, "position", null, Vector2(0,-$Table.texture.get_height()), paper_fly_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	_start_round()


# Remove all the food from the board.
# This is called when the interstitial flies over
func _clear_food()->void:
	for food in $Food.get_children():
		$Food.remove_child(food)
		food.queue_free()


# Speed everything up
func _engage_warp_speed():
	# This is only allowed if we are in the editor, not when deployed.
	if not OS.has_feature("standalone"):
		round_duration = 3
		$AnimationPlayer.playback_speed = 3
		paper_fly_duration = .5


func _on_MainMenu_about_selected():
	# TODO: Disable other buttons
	$AnimationPlayer.play("FlyInCredits")
	

func _on_Credits_dismissed():
	# TODO: Disable other buttons
	$AnimationPlayer.play_backwards("FlyInCredits")
	$MainMenu.enable_buttons()
