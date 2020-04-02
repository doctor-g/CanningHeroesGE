extends "../Food.gd"

var _chop_point2 : ChopPoint
var ChopPointScene : PackedScene = preload("res://src/Food/ChopPoint.tscn")

func _on_ChopPoint_chop():
	$ChopSound.play()
	$AnimationPlayer.play("Split1")

func _spawn_second_chop_point()->void:
	_chop_point2 = ChopPointScene.instance()
	$Offset/SecondPart/ThirdPart/CarrotBottom.add_child(_chop_point2)
	_chop_point2.connect("chop", self, "_on_ChopPoint2_chop", [], CONNECT_ONESHOT)
	
	
func _on_ChopPoint2_chop()->void:
	$ChopSound.play()
	$AnimationPlayer.play("Split2")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Split2":
		emit_signal("processed")


func _set_enabled(value):
	._set_enabled(value)
	if not enabled:
		_remove_all_chop_points_from(self)


# Recursively remove all chop points from the scene.
func _remove_all_chop_points_from(node : Node):
	for child in node.get_children():
		if child is ChopPoint:
			node.remove_child(child)
			child.queue_free()
		else:
			_remove_all_chop_points_from(child)
