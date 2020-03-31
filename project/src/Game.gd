extends Node2D

var Carrot = preload("res://src/Food/Carrot/CleanableCarrot.tscn")

onready var _workstations := []
onready var _tween_pool : TweenPool = $TweenPool
onready var _tray : Tray = $Tray

# Number of fruits completed
var _completed := 0

func _ready():
	_workstations = $Workstations.get_children()
	for workstation in _workstations:
		_add_carrot_to(workstation)

	
func _add_carrot_to(workstation):
	var tween = _tween_pool.create()
	var source = workstation.spawn_point.get_global_transform().origin
	var destination = workstation.get_global_transform().origin
	var carrot = Carrot.instance()
	carrot.position = source
	carrot.rotation_degrees = rand_range(1,360)
	$Food.add_child(carrot)
	tween.interpolate_property(carrot, "position", source, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	carrot.connect("cleaned", self, "_on_carrot_cleaned", [carrot, workstation])


func _on_carrot_cleaned(carrot:Area2D, workstation):
	# Track completion and adjust Z so the latest is on top
	_completed = _completed + 1
	carrot.z_index = _completed
	
	# Fly the carrot to the tray
	var tween = _tween_pool.create()
	var destination = _tray.get_global_transform().xform(_tray.get_food_target())
	tween.interpolate_property(carrot, "position", null, destination, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	# Add a new carrot
	_add_carrot_to(workstation)
