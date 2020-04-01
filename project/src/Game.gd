extends Node

export(int) var round_duration := 30
export(float) var paper_fly_duration := 1.5

# This is an awkward workaround the lack of a timer.is_active method
var _has_timer_started := false

const CARROT_GAME := [
	{
		"food": preload("res://src/Food/Carrot/CleanableCarrot.tscn"),
		"label": "Wash the Carrots!",
	},
	{
		"food": preload("res://src/Food/Carrot/PeelableCarrot.tscn"),
		"label": "Peel the Carrots!",
	}
]

onready var _workstations := []
onready var _tween_pool : TweenPool = $TweenPool
onready var _tray : Tray = $Tray
onready var _timer : Timer = $Timer
onready var _ui_timer : GameTimer = $Interface/GameTimer

onready var _game_config : Array = CARROT_GAME
onready var _round : int = 0
onready var _GameOverScene := preload("res://src/UI/GameOver.tscn")

# Number of fruits completed
var _completed := 0

func _ready():
	_workstations = $Workstations.get_children()
	
	
func _start_round():
	$Interstitial.update_label(_game_config[_round]["label"])
	$Interstitial.z_index = _completed + 1 # Force on top of food pile
	$AnimationPlayer.play("InterstitialFlyBy")
	
	
func _on_interstitialflyby_finished()->void:
	for workstation in _workstations:
		_add_food_to(workstation)
	_timer.start(round_duration)
	_has_timer_started = true
	
	
func _process(_delta:float):
	_ui_timer.update_time_remaining(_timer.time_left if _has_timer_started else float(round_duration))


func _input(event):
	if event.is_action_pressed("engage_warp_speed"):
		_engage_warp_speed()

	
func _add_food_to(workstation:Node2D):
	var tween = _tween_pool.create()
	var source = workstation.spawn_point.get_global_transform().origin
	var destination = workstation.get_global_transform().origin
	var food = _game_config[_round]["food"].instance()
	food.position = source
	food.rotation_degrees = rand_range(1,360)
	$Food.add_child(food)
	tween.interpolate_property(food, "position", source, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	food.connect("processed", self, "_on_food_processed", [food, workstation])


func _on_food_processed(food:Food, workstation):
	# Track completion and adjust Z so the latest is on top
	_completed = _completed + 1
	food.z_index = _completed
	
	# Fly the food to the tray
	var tween = _tween_pool.create()
	var destination = _tray.get_global_transform().xform(_tray.get_food_target())
	tween.interpolate_property(food, "position", null, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	# Add a new food
	_add_food_to(workstation)


func _on_Timer_timeout():
	# Prevent further interaction with the food on the table
	for food in $Food.get_children():
		(food as Food).enabled = false
		
	# Advance the round
	_round += 1
	
	# If the game is over, set up and fly in the GameOver scene
	if _round == _game_config.size():
		var game_over_scene : Sprite = _GameOverScene.instance()
		game_over_scene.z_index = _completed  # Force on top of food pile
		add_child(game_over_scene)
		game_over_scene.position = Vector2(0,-game_over_scene.texture.get_height())
		var tween : Tween = _tween_pool.create()
		tween.interpolate_property(game_over_scene, "position", null, Vector2.ZERO, paper_fly_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		
	# Otherwise start the next round
	else:
		_start_round()


func _on_MainMenu_game_selected(selection):
	match selection:
		"carrot":
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
	_has_timer_started = false


func _engage_warp_speed():
	print(OS.is_debug_build())
	round_duration = 3
	$AnimationPlayer.playback_speed = 3
	paper_fly_duration = .5
