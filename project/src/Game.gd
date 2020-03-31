extends Node

export(int) var round_duration := 30
export(float) var paper_fly_duration := 1.5

# This is an awkward workaround the lack of a timer.is_active method
var _has_timer_started := false

const CARROT_ROUND := {
	"food": preload("res://src/Food/Carrot/CleanableCarrot.tscn")
}

onready var _workstations := []
onready var _tween_pool : TweenPool = $TweenPool
onready var _tray : Tray = $Tray
onready var _timer : Timer = $Timer
onready var _ui_timer : GameTimer = $Interface/GameTimer

onready var _round_config := CARROT_ROUND
onready var _GameOverScene := preload("res://src/UI/GameOver.tscn")

# Number of fruits completed
var _completed := 0

func _ready():
	_workstations = $Workstations.get_children()
	
	
func _start_game():
	for workstation in _workstations:
		_add_food_to(workstation)
	_timer.start(round_duration)
	_has_timer_started = true
	
	
func _process(_delta:float):
	_ui_timer.update_time_remaining(_timer.time_left if _has_timer_started else round_duration)

	
func _add_food_to(workstation:Node2D):
	var tween = _tween_pool.create()
	var source = workstation.spawn_point.get_global_transform().origin
	var destination = workstation.get_global_transform().origin
	var food = _round_config["food"].instance()
	food.position = source
	food.rotation_degrees = rand_range(1,360)
	$Food.add_child(food)
	tween.interpolate_property(food, "position", source, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	food.connect("processed", self, "_on_food_processed", [food, workstation])


func _on_food_processed(food:Area2D, workstation):
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
	# Set up and fly in the GameOver scene
	var game_over_scene : Sprite = _GameOverScene.instance()
	game_over_scene.z_index = _completed  # Force on top of food pile
	add_child(game_over_scene)
	game_over_scene.position = Vector2(0,-game_over_scene.texture.get_height())
	var tween : Tween = _tween_pool.create()
	tween.interpolate_property(game_over_scene, "position", null, Vector2.ZERO, paper_fly_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	# Prevent further interaction with the food on the table
	for food in $Food.get_children():
		(food as Food).enabled = false


func _on_MainMenu_game_selected(selection):
	match selection:
		"carrot":
			var tween : Tween = _tween_pool.create()
			tween.interpolate_property($MainMenu, "position", null, Vector2(0,-$Table.texture.get_height()), paper_fly_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.start()
			tween.connect("tween_completed", self, "_on_MainMenu_fly_out_completed", [], CONNECT_ONESHOT)

func _on_MainMenu_fly_out_completed(_object, _path):
	_start_game()
