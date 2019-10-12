extends Node
class_name Board

var dynamic_blocks : DynamicBlocks;
var cursor : Cursor;
var view : Node2D;

func _ready() -> void:
	self.dynamic_blocks = DynamicBlocks.new();
	self.add_child(dynamic_blocks);
	self.cursor = Cursor.new();
	self.add_child(cursor);
	self.view = load("res://board/BoardView.tscn").instance();
	self.add_child(view);
	
	view.get_node("DynamicBlocksViewDebug").model_path = dynamic_blocks.get_path()
	view.get_node("CursorViewDebug").model_path = cursor.get_path()
	
	self.dynamic_blocks.connect("new_exploder", view.get_node("DynamicBlocksViewDebug"), "new_exploder");
	self.dynamic_blocks.connect("new_faller", view.get_node("DynamicBlocksViewDebug"), "new_faller");
	self.cursor.connect("raise_requested", dynamic_blocks, "raise");
	self.cursor.connect("swap_requested", dynamic_blocks, "swap");