extends Node2D

func _ready() -> void:
	var b1 : Board = Board.new();
	b1.name = "Board"
	add_child(b1);
	$BoardView.set_model(b1);