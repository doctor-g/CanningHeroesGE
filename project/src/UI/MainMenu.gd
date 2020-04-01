extends Sprite

signal game_selected(selection)

onready var _fullscreen_toggle = $Interface/TextureRect/FullscreenToggle

func _on_CarrotButton_pressed():
	emit_signal("game_selected", "carrot")


func _on_FullscreenToggle_pressed():
	OS.window_fullscreen = _fullscreen_toggle.pressed
