extends Node
class_name Food

# Emitted when this food is fully processed
# warning-ignore:unused_signal
signal processed(food, good_parts, scrap)

var enabled := true setget _set_enabled

func _set_enabled(value)->void:
	enabled = value
