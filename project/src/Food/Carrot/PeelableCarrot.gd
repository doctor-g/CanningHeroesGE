extends "../Food.gd"

const _IMAGES := [
	preload("res://assets/food/carrot_peeled_1.png"),
	preload("res://assets/food/carrot_peeled_2.png"),
	preload("res://assets/food/carrot_peeled_3.png")
]

enum State {
	DEFAULT,
	TOUCH_TOP,
	TOUCH_BOTTOM
}

var _state = State.DEFAULT

# Current position in the _IMAGES array
var _next_image_index := 0

onready var _sprite : Sprite = $Sprite
onready var _interaction_area : Area2D = $Sprite/InteractionArea

# shape_idx is "the child index of the clicked Shape2D".
func _on_InteractionArea_input_event(_viewport, event:InputEvent, shape_idx:int):
	if not event is InputEventScreenDrag:
		return
	match _state:
		State.DEFAULT:
			_state = State.TOUCH_TOP if shape_idx == 0 else State.TOUCH_BOTTOM
		State.TOUCH_TOP:
			if shape_idx == 1:
				_peel()
		State.TOUCH_BOTTOM:
			if shape_idx == 0:
				_peel()
				
func _peel():
	_state = State.DEFAULT
	_sprite.texture = _IMAGES[_next_image_index]
	_next_image_index += 1
	$PeelingSound.play()
	if _next_image_index == _IMAGES.size():
		emit_signal("processed", self, [$Sprite], [])
		_remove_interaction_areas()
		
# Remove the interaction areas if they still exist
func _remove_interaction_areas()->void:
	if is_instance_valid(_interaction_area) and _interaction_area.get_parent()==_sprite:
		_sprite.remove_child(_interaction_area)
		_interaction_area.queue_free()
		
func _set_enabled(value):
	._set_enabled(value)
	if not value:
		_remove_interaction_areas()
