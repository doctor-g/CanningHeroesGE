tool
extends Sprite
class_name Tray

# The size of the margin where food will not end up
export(Vector2) var landing_extents := Vector2(100,100) setget _set_landing_extents

func _draw():
	if Engine.is_editor_hint():
		var rect := Rect2(-landing_extents.x, -landing_extents.y, landing_extents.x*2, landing_extents.y*2)
		draw_rect(rect, Color(.1,.1,.8,.2), true)
		
func _set_landing_extents(value):
	landing_extents = value
	update()

# Get a location to put a food item within this object's coordinate space
func get_food_target() -> Vector2:
	var x := rand_range(-landing_extents.x, landing_extents.x)
	var y := rand_range(-landing_extents.y, landing_extents.y)
	return Vector2(x,y)
