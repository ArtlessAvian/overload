extends Node2D

var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

var move_queue : Array = []; # Of Vector2Int Cursor Positions

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
#	blocks.connect()
	
	cursor.player = "ai"; # Call methods directly instead.
#	observe_board()

func temp_sorty_thing(x : int, y : int):
	if y < len(blocks.board[x]):
		if blocks.board[x][y] != board_options.CLEARING:
			return blocks.board[x][y];
		return -1; # error code
	return 100 * sign(float((y + blocks.line_count) % 2) - 0.5); # push empty space alternating left and right

func queue_moves() -> void:
	# Pick a random row, and attempt to make it more sorted.
	var shuffle = [];
	for i in range(self.board_options.board_height-1, self.board_options.board_height-4, -1):
		shuffle.append(i);
	for i in range(self.board_options.board_height-3):
		shuffle.append(i);
	
	for row in shuffle:
		for j in range(self.board_options.board_width-1):
			var left = temp_sorty_thing(j, row);
			var right = temp_sorty_thing(j + 1, row);
			if left > right and left != -1 and right != -1:
				move_queue.append(Vector2(j, row));
				return;

#func observe_board() -> void:
#	var rows_contents = [];
#	for i in range(self.board_options.board_height):
#		var row_contents = [];
#		for j in range(self.board_options.board_width):
#			if i < len(blocks.board[j]):
#				row_contents.append(blocks.board[j][i]);
#
#		if row_contents.empty():
#			break;
#		rows_contents.append(row_contents);
#	print(rows_contents);

func _physics_process(delta: float) -> void:
	if blocks.tallest_column_height() < 8:
		cursor.request_raise();
	
	if move_queue.empty():
		queue_moves();
	
	counter += delta;
	if counter > 0.1:
		counter -= 0.1;
		if not move_queue.empty():
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