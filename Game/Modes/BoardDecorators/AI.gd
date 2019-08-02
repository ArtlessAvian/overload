extends Node2D

#var board_options : BoardOptions = preload("res://Options/Default.tres");
#func set_board_options(thing : BoardOptions):
#	self.board_options = thing;

#var delta_x : int = 0;
#var delta_y : int = 0;
#
#var hesitation : float = 0;
#var apm : float = 0;
var counter : float = 0;

var to_decorate : Board;
var blocks : Blocks;
var cursor : Cursor; # : Cursor;

func _ready() -> void:
	to_decorate = get_parent();
	blocks = to_decorate.get_node("Blocks");
	cursor = blocks.get_node("Cursor");
	
	cursor.player = "ai"; # Call methods directly instead.

var temp_up = false;
var temp_left = false;

func _physics_process(delta: float) -> void:
	counter += delta;
	if blocks.tallest_column_height() < 10:
		cursor.request_raise()
	
	match (randi() % 3):
		0:
			if temp_up:
				cursor.cursor_up() 
			else:
				cursor.cursor_down();
		1:
			if temp_left:
				cursor.cursor_left() 
			else:
				cursor.cursor_right();
		2:
			cursor.cursor_swap();
			if randf() > 0.5:
				temp_up = not temp_up;
			else:
				temp_left = not temp_left;