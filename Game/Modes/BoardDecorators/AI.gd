extends Node
class_name AI

var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

var to_decorate : Board;
var blocks : Blocks;
var cursor : Cursor; # : Cursor;

var move_queue : Array = []; # Of Vector2Int Cursor Positions
var cursoring_apm : float = 300;

func _ready() -> void:
	to_decorate = get_parent();
	blocks = to_decorate.get_node("Blocks");
	cursor = blocks.get_node("Cursor");
#	blocks.connect()
	cursor.player = "ai"; # Call methods directly instead.

func queue_moves() -> void:
	print("this should never happen!");
	print("moves should be queued here though");
	print("and delay for \"thinking\"");
	delay = 100000;

var delay : float = 0;
func _physics_process(delta: float) -> void:
	delay -= delta;
	if delay > 0:
		return;
	
	if move_queue.empty():
		self.queue_moves();
	
	if delay > 0:
		return;
	
	if not move_queue.empty():
		delay += get_cursoring_frequency()
		if cursor.cursor_pos == move_queue[0]:
			cursor.cursor_swap();
			move_queue.pop_front();
		else:
			if cursor.cursor_pos.x < move_queue[0].x:
				cursor.cursor_right();
			if cursor.cursor_pos.x > move_queue[0].x:
				cursor.cursor_left();
			if cursor.cursor_pos.y < move_queue[0].y:
				cursor.cursor_up();
			if cursor.cursor_pos.y > move_queue[0].y:
				cursor.cursor_down();

func get_cursoring_frequency():
	return 60.0/self.cursoring_apm;