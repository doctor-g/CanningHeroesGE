extends "../Food.gd"

const IMAGES := [
	null, # We do not need the image here since it's already set on the sprite
		  # but we do need to fill the slot to keep step counting sensible
	preload("res://assets/food/tomato_peel1.png"),
	preload("res://assets/food/tomato_peel2.png"),
	preload("res://assets/food/tomato_peeled.png"),
]

enum State {
	IDLE,
	TOP_TOUCH,
	BOTTOM_TOUCH,
}

var _step := 0

# The state of interaction
var _state = State.IDLE


func _on_TopArea_input_event(_viewport, event, _shape_idx):
	if  event is InputEventScreenDrag:
		match _state:
			State.IDLE:
				_state = State.TOP_TOUCH
			State.BOTTOM_TOUCH:
				_advance_step()


func _on_BottomArea_input_event(_viewport, event, _shape_idx):
	if  event is InputEventScreenDrag:
		match _state:
			State.IDLE:
				_state = State.BOTTOM_TOUCH
			State.TOP_TOUCH:
				_advance_step()


func _advance_step()->void:
	$PeelSound.play()
	_state = State.IDLE
	_step += 1
	$Sprite.texture = IMAGES[_step]
	if _step == IMAGES.size() - 1:
		_remove_interaction_areas()
		emit_signal("processed", self, [$Sprite], [])
		
		
func _remove_interaction_areas():
	for i in ["TopArea", "BottomArea"]:
		if has_node(i):
			var node:Node = get_node(i)
			remove_child(node)
			node.queue_free()


func _set_enabled(value):
	._set_enabled(value)
	if not enabled:
		_remove_interaction_areas()
