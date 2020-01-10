extends Node2D

func _ready() -> void:
	var b1 : Board = Board.new();
	b1.name = "Board"
	add_child(b1);
	$BoardView.set_model(b1);
	
	var b2 : Board = Board.new();
	b2.name = "Board2"
	add_child(b2);
	$BoardView2.set_model(b2);
	
	$Board/DynamicBlocks.connect("clear", self, "on_clear");
	$Board2/DynamicBlocks.connect("clear", self, "on_clear2");

func on_clear(clears : Array, chain : int):
	forward_garbage($Board2, chain + len(clears) - 3)

func on_clear2(clears : Array, chain : int):
	forward_garbage($Board, chain + len(clears) - 3)

func forward_garbage(target : Board, amount : int):
	target.get_node("DynamicBlocks").receive_garbage(amount);