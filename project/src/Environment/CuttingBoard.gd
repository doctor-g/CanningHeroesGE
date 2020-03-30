tool
extends Sprite

export(Vector2) var fly_in_source := Vector2(300,300) setget _set_fly_in_source
export(Vector2) var fly_out_destination := Vector2(-300,300) setget _set_fly_out_destination
export var flight_duration := 1.0

onready var _fly_in := $FlyInTween
onready var _fly_out := $FlyOutTween

# Called when the node enters the scene tree for the first time.
func _ready():
	var _e = _fly_out.connect("tween_completed", self, "_on_fly_out_completed")


func _draw():
	if not Engine.editor_hint:
		return
	draw_line(fly_in_source, Vector2.ZERO, Color.blue, 2)
	draw_line(fly_out_destination, Vector2.ZERO, Color.blue, 2)


# Add a vegetable to the cutting board
func add(veggie:Node2D)->void:
	add_child(veggie)
	_fly_in.interpolate_property(veggie, "position", fly_in_source, Vector2.ZERO, flight_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_fly_in.start()
	var _e = veggie.connect("cleaned", self, "_on_veggie_cleaned", [veggie])

	
func _on_veggie_cleaned(veggie)->void:
	_fly_out.interpolate_property(veggie, "position", null, fly_out_destination, flight_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_fly_out.start()


func _on_fly_out_completed(object, _key)->void:
	object.queue_free()


func _set_fly_in_source(value: Vector2):
	fly_in_source = value
	update()

	
func _set_fly_out_destination(value: Vector2):
	fly_out_destination = value
	update()
