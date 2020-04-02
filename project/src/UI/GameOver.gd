extends Sprite
class_name GameOver

# The number of veggies completed
var number_completed : int = 0 setget _set_number_completed

# The veggie being completed
var food_name : String = "Soylent Green" setget _set_food_name

func _set_number_completed(value)->void:
	number_completed = value
	_update_label_text()
	
func _update_label_text()->void:
	$Control/Label.text = "You canned %d %s!" % [number_completed, food_name]
	
func _set_food_name(value)->void:
	food_name = value
	_update_label_text()


func _on_OkButton_pressed():
	# If we leave right away, the sound gets cut off, so wait for it to finish.
	$ButtonClickSound.play()
	$ButtonClickSound.connect("finished", self, "_on_click_sound_finished", [], CONNECT_ONESHOT)
	$Control/OkButton.disabled = true


func _on_click_sound_finished()->void:
	get_tree().change_scene("res://src/Game.tscn")
