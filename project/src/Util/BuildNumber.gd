extends Node
class_name BuildNumber

const BUILD_NUMBER_PATH := "res://build_number.tres"

var value : int

func _init():
	var f:File = File.new()
	f.open(BUILD_NUMBER_PATH, File.READ)
	var t = f.get_as_text()
	value = int(t)	
