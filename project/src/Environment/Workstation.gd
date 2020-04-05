tool
extends Node2D

# The point at which this workstation's fruit should spawn in
onready var spawn_point : Node2D = $SpawnPoint

# Draw the spawn point for convenience in the editor
func _draw():
	if Engine.is_editor_hint():
		draw_circle(spawn_point.position, 5, Color.red)

# Get the scrap point in this scene's coordinate space
func get_scrap_point():
	return $ScrapPoint.position
