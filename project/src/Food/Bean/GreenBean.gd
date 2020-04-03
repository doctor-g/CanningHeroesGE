extends "../Food.gd"

var _chops := 0

func _on_TopChop_chop():
	$SnapSound.play()	
	$AnimationPlayer.play("SnapTop")


func _on_BottomChop_chop():
	$SnapSound.play()	
	$AnimationPlayer.play("SnapBottom")


func _on_chop_animation_complete():
	_chops += 1
	if _chops == 2:
		emit_signal("processed")
