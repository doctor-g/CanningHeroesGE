extends Sprite

signal game_selected(selection)

func _on_CarrotButton_pressed():
	emit_signal("game_selected", "carrot")
