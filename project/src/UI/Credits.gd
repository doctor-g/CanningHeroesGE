extends Node2D

signal dismissed


func _on_BackButton_pressed():
	$ButtonClickSound.play()
	emit_signal("dismissed")
