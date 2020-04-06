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
	if _chops == 2 and enabled: # Enabled check prevents beans finishing after timer ends.
		var bottom = $Sprites/Bottom/BottomSprite
		var mid = $Sprites/MiddleSprite
		var top = $Sprites/Top/TopSprite
		emit_signal("processed", self, [bottom,mid], [top])


func _set_enabled(value)->void:
	._set_enabled(value)
	# If this is called during destruction, then the usual dollar-sign
	# references may be invalid, hence the following
	for name in ["TopChop", "BottomChop"]:
		if has_node(name):
			get_node(name).enabled = value
