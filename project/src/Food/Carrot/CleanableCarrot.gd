extends "../Food.gd"

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
onready var _scrub_sound : AudioStreamPlayer2D = $ScrubSound

func _process(delta:float):
	if enabled and _is_scrubbing and not _is_clean:
		var prev :Color = dirt.self_modulate
		var new_alpha : float = prev.a - clean_rate * delta
		if new_alpha <= 0:
			dirt.visible = false
			_is_clean = true
			_set_enabled(false)
			emit_signal("processed", self, [$Carrot], [])
		else:
			dirt.self_modulate = Color(prev.r, prev.g, prev.b, new_alpha)
		if not _scrub_sound.playing:
			_scrub_sound.play()
		_is_scrubbing = false


# Check if we are currently scrubbing the carrot
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenDrag:
		_is_scrubbing = true


func _set_enabled(value)->void:
	._set_enabled(value)
	if not enabled:
		$CollisionShape2D.disabled = true
