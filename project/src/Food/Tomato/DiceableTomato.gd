extends "../Food.gd"

var _sides_complete := 0

func _set_enabled(value)->void:
	._set_enabled(value)
	if not enabled:
		# Remove all chop areas
		for i in ["MiddleChopArea", "LeftChopArea", "RightChopArea"]:
			if has_node(i):
				var node = get_node(i)
				node.queue_free()
				remove_child(node)


func _on_MiddleChopArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		$AnimationPlayer.play("MiddleChop")
		$DiceSound.play()
		$MiddleChopArea.queue_free()
		remove_child($MiddleChopArea)
			
	
func _enable_side_chop_areas():
	for i in [$LeftChopArea/CollisionShape2D, $RightChopArea/CollisionShape2D]:
		i.disabled = false


func _on_LeftChopArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		_side_chop("LeftChop", $LeftChopArea)


func _on_RightChopArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		_side_chop("RightChop", $RightChopArea)


func _side_chop(anim_name:String, area_to_remove:Node)->void:
	$AnimationPlayer.play(anim_name)
	$DiceSound.play()
	if is_instance_valid(area_to_remove):
		area_to_remove.queue_free()
		remove_child(area_to_remove)

func _on_side_animation_complete()->void:
	_sides_complete += 1
	if _sides_complete == 2:
		emit_signal("processed")
