extends "../AI.gd"

# Strangely breaks at 400 APM. Super weird!!

#var board_options : BoardOptions = preload("res://Options/Default.tres");
#var move_queue : Array = []; # Of Vector2Int Cursor Positions
#var to_decorate : Board;
#var blocks : Blocks;
#var cursor : Cursor; # : Cursor;

func _ready() -> void:
	._ready();

func thingy(x : int, y : int):
	if y < len(blocks.board[x]):
#		if blocks.board[x][y] != board_options.CLEARING:
		return blocks.board[x][y];
#		return -1; # error code
	return 100 * sign(float((y + blocks.line_count) % 2) - 0.5); # push empty space alternating left and right

func queue_moves() -> void:
	for row in range(self.board_options.board_height):
		for j in range(self.board_options.board_width-1):
			var left = thingy(j, row);
			var right = thingy(j + 1, row);
			if left > right and left != -1 and right != -1:
				move_queue.append(Vector2(j, row));
				return;
	delay += 1;
	move_queue.append(Vector2(randi() % (self.board_options.board_width-1), randi() % blocks.tallest_column_height()))

func _physics_process(delta: float) -> void:
#	if blocks.tallest_column_height() < 8:
#		cursor.request_raise();
	
#	print(move_queue, cursor.cursor_pos)
	._physics_process(delta);