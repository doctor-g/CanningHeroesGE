extends Sprite

onready var _label : Label = $Control/Label

func update_label(text:String)->void:
	_label.text = text
