extends Sprite

signal game_selected(selection)
signal about_selected

onready var _fullscreen_toggle : TextureButton = $Interface/TextureRect/FullscreenToggle

func _ready():
	var b = BuildNumber.new()
	$Interface/BuildNumber.text = "Build %d" % b.value
	
	
func enable_buttons():
	get_tree().call_group("buttons", "set_disabled", false)
	
	
func disable_buttons():
	get_tree().call_group("buttons", "set_disabled", true)


func _on_CarrotButton_pressed():
	_process_game_button_press("carrot")
	

func _process_game_button_press(name:String)->void:
	disable_buttons()
	_play_button_click_sound()
	emit_signal("game_selected", name)
	

func _on_BeanButton_pressed():
	_process_game_button_press("bean")
	

func _on_TomatoButton_pressed():
	_process_game_button_press("tomato")


func _on_FullscreenToggle_pressed():
	_play_button_click_sound()
	OS.window_fullscreen = _fullscreen_toggle.pressed


func _play_button_click_sound()->void:
	$ButtonClickSound.play()


func _on_AboutButton_pressed():
	$JarClinkSound.play()
	disable_buttons()
	emit_signal("about_selected")
