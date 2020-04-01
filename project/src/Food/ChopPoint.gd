extends Area2D

signal chop
class_name ChopPoint

export(float) var radius = 0
var _is_choppable := false 
var _last_radius : float = 0

onready var _collision_shape : CollisionShape2D = $CollisionShape2D
onready var _animation_player : AnimationPlayer = $AnimationPlayer


func _ready():
	_animation_player.play("Spawn")


func _draw():
	draw_circle(Vector2.ZERO, radius, Color.red)


func _process(_delta:float):
	if _last_radius != radius:
		_last_radius = radius
		update()


func _on_ChopPoint_input_event(_viewport, event, _shape_idx):
	if _is_choppable and event is InputEventMouseButton and event.pressed:
		_is_choppable = false
		emit_signal("chop")
		_animation_player.play("Despawn")
	
	
func _enable_chop()->void:
	_is_choppable = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="Despawn":
		queue_free()
