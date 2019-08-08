extends "../AI.gd"

#var board_options : BoardOptions = preload("res://Options/Default.tres");
#var move_queue : Array = []; # Of Vector2Int Cursor Positions
#var to_decorate : Board;
#var blocks : Blocks;
#var cursor : Cursor; # : Cursor;

func _ready() -> void:
	._ready();

func queue_moves() -> void:
#	if blocks.any_exploder_active():
		# Extend combo
		do_raise();
#	else:
		# Start combo, Clear garbage, Raise Board
		if not start_combo():
			do_raise();
			flatten();

func start_combo() -> bool:
	var last_two_rows = [null, null];
	for row in range(blocks.tallest_column_height()):
		var row_contents = get_row(row);
		
		# Attempt to match horizontal
		var count = [];
		for _color in range(board_options.color_count):
			count.append(0);
		for content in row_contents:
			if 0 <= content and content < board_options.color_count:
				count[content] += 1;

		for color in range(board_options.color_count):
			if count[color] >= 3:
				var left = row_contents.find(color);
				var mid = row_contents.find(color, left+1);
				var right = row_contents.find(color, mid+1);
				queue_transfer(Vector2(left, row), Vector2(mid-1, row))
				queue_transfer(Vector2(right, row), Vector2(mid+1, row))
#				delay = 1;
				return true;
		
		# Attempt to match vertical
		last_two_rows.append(row_contents);
		if not (null in last_two_rows):
			for color in range(board_options.color_count):
				var found = true;
				for a_row in last_two_rows:
					if not (color in a_row):
						found = false;
						break;
				if found:
					var clear_col = last_two_rows[2].find(color)
					queue_transfer(Vector2(last_two_rows[0].find(color), row-2), Vector2(clear_col, row-2));
					queue_transfer(Vector2(last_two_rows[1].find(color), row-1), Vector2(clear_col, row-1));
#					delay = 1;
					return true;
		last_two_rows.pop_front();
		
	return false;

func do_raise() -> bool:
	if blocks.tallest_column_height() < 9:
		cursor.request_raise();
	return true;

func flatten() -> bool:
	var previous = len(blocks.board[0]);
	for col in range(1, board_options.board_width):
		var current = len(blocks.board[col]);
		if abs(current - previous) >= 2:
			move_queue.append(Vector2(col-1, min(current, previous)))
#			delay = 0.1;
			return true;
		previous = current;
	return false;

func queue_transfer(from : Vector2, to : Vector2) -> void:
	assert(from.y == to.y);
	# for is skipped if moving left
	for i in range(from.x, to.x):
		move_queue.append(Vector2(i, to.y));
	# for is skipped if moving right
	for i in range(from.x, to.x, -1):
		move_queue.append(Vector2(i-1, to.y));

func get_row(row):
	var out = [];
	for col in range(board_options.board_width):
		out.append(get_oob(col, row))
	return out;

func get_oob(col : int, row : int):
	if row < len(blocks.board[col]):
		return blocks.board[col][row];
	return -1;

func _physics_process(delta: float) -> void:
	._physics_process(delta);