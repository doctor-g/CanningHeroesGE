extends Control
class_name GameTimer

onready var _label : Label = $Label

func update_time_remaining(seconds:float)->void:
	var displayable_seconds = ceil(seconds)
	_label.text = "%d" % int(displayable_seconds)
