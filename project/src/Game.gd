extends Node2D


var Carrot = preload("res://src/Food/Carrot/CleanableCarrot.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	_add_carrot()
	
	
func _add_carrot():
	var carrot = Carrot.instance()
	$CuttingBoard.add(carrot)
	carrot.connect("cleaned", self, "_on_carrot_cleaned", [carrot])


func _on_carrot_cleaned(carrot):
	_add_carrot()
