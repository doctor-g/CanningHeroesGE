extends Area2D

signal cleaned()

# How far to move to count as movement when scrubbing
export var movement_threshold_squared := 1

# How much to clean each step
export var clean_rate := 1

# This value is "produced" by the input event and "consumed" in process.
# This protocol prevents us from continuing to scrub when we are not 
# getting input events.
var _is_scrubbing := false
var _last_touch := Vector2()
var _is_clean := false

onready var dirt : Sprite = $Carrot/Dirt

func _process(delta:float):
	if _is_scrubbing and not _is_clean:
		var prev :Color = dirt.self_modulate
		var new_alpha : float = prev.a - clean_rate * delta
		if new_alpha <= 0:
			dirt.visible = false
			_is_clean = true
			emit_signal("cleaned")
		else:
			dirt.self_modulate = Color(prev.r, prev.g, prev.b, new_alpha)
		_is_scrubbing = false


# Check if we are currently scrubbing the carrot
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenDrag:
		_is_scrubbing = true
