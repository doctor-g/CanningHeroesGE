extends Node
class_name TweenPool

export(int) var initial_size = 4

var _pool := []

func _ready():
	for _i in range(4):
		 # warning-ignore:return_value_discarded
		_make_tween_in_pool()
		
func _make_tween_in_pool() -> Tween:
	var tween : Tween = Tween.new()
	add_child(tween)
	_pool.append(tween)
	return tween
	
func create() -> Tween:
	var tween : Tween = _pool.pop_back()
	if not tween:
		tween = _make_tween_in_pool()
	# warning-ignore:return_value_discarded
	tween.connect("tween_all_completed", self, "_on_tween_all_completed", [tween], CONNECT_ONESHOT)
	return tween
	
func _on_tween_all_completed(tween:Tween)->void:
	_pool.append(tween)

