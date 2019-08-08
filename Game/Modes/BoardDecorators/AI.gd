extends Node
class_name AI

var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

var to_decorate : Board;
var blocks : Blocks;
var cursor : Cursor; # : Cursor;

var move_queue : Array = []; # Of Vector2Int Cursor Positions
var cursoring_apm : float = 400;

func _ready() -> void:
	to_decorate = get_parent();
	blocks = to_decorate.get_node("Blocks");
	cursor = blocks.get_node("Cursor");
	blocks.connect("true_raise", self, "_on_Blocks_true_raise");
	cursor.player = "ai"; # Call methods directly instead.

func _on_Blocks_true_raise():
	for i in range(len(move_queue)):
		move_queue[i].y += 1;
	
func queue_moves() -> void:
	print("this should never happen!");
	print("moves should be queued here though");

var delay : float = 0;
func _physics_process(delta: float) -> void:
	delay -= delta;
	if delay > 0:
		return;
		
	if move_queue.empty():
		self.queue_moves();
	
	if not move_queue.empty():
		if cursor.cursor_pos == move_queue[0] and blocks.is_physics_processing():
			cursor.cursor_swap();
			move_queue.pop_front();
			delay = 1.0/60; # 1 frame, magic number. forces next observation to better reflect the gamestate.
		else:
			assert(0 <= move_queue[0].x)
			assert(move_queue[0].x < board_options.board_width);
			delay = get_cursoring_frequency()
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