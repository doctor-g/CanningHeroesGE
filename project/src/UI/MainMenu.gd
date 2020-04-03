extends Sprite

signal game_selected(selection)

onready var _fullscreen_toggle = $Interface/TextureRect/FullscreenToggle

func _ready():
	var b = BuildNumber.new()
	$Interface/BuildNumber.text = "Build %d" % b.value
	

func _on_CarrotButton_pressed():
	_play_button_click_sound()
	emit_signal("game_selected", "carrot")
	
func _on_BeanButton_pressed():
	_play_button_click_sound()
	emit_signal("game_selected", "bean")


func _on_FullscreenToggle_pressed():
	_play_button_click_sound()
	OS.window_fullscreen = _fullscreen_toggle.pressed


func _play_button_click_sound()->void:
	$ButtonClickSound.play()



