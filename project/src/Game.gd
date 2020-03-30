extends Node2D

var Carrot = preload("res://src/Food/Carrot/CleanableCarrot.tscn")

onready var _cutting_boards := []

# Called when the node enters the scene tree for the first time.
func _ready():
	_cutting_boards = $CuttingBoards.get_children()
	for item in _cutting_boards:
		_add_carrot_to(item)
	
	
func _add_carrot_to(board):
	var carrot = Carrot.instance()
	board.add(carrot)
	carrot.connect("cleaned", self, "_on_carrot_cleaned", [board])


func _on_carrot_cleaned(board):
	_add_carrot_to(board)
