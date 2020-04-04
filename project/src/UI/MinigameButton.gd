tool
extends Node2D

signal pressed

export(Texture) var image = preload("res://assets/ui/bean_icon.png") setget _set_image
export(String) var label = "Instructions!" setget _set_label_text

# Play the pulse animation
func pulse():
	$AnimationPlayer.play("Pulse")


func _set_image(value:Texture)->void:
	image = value
	$Sprite.texture = value
	

func _set_label_text(value:String)->void:
	label = value
	$Label.text = value


func _on_Area2D_input_event(_viewport, event:InputEvent, _shape_idx):
	if event.is_pressed():
		emit_signal("pressed")
