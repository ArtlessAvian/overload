extends Node2D
class_name Blocks

# Jagged Array
var _static_blocks : Array = [];
var _chain_checker : Array = []; # Working in parallel.
var _queued_rows : Array = [[], [], []]; # 3 x Cols Array. Dequeues from the front.

var _queue_check : bool;

#func dequeue_queued_row():
#	var to_return = _queued_rows.pop_back();
#	var new_row = [];
#	for i in range(self.get_width()):
#		new_row.append(randi() % 6);
#	_queued_rows.push_front(new_row);
#	return to_return;

func set_width(width):
	while len(_static_blocks) != width:
		_static_blocks.append([]);
		_chain_checker.append([]);
		for row in _queued_rows:
			row.append(-1);

func get_width():
	assert(len(_static_blocks) == len(_chain_checker));
	return len(_static_blocks);

static func detect_in_a_row(row):
	var out = []
	
	var doubles = [];
	for i in range(0, len(row)-1):
		doubles.append(row[i] == row[i+1])
	for i in range(0, len(doubles)-1):
		if doubles[i] and doubles[i+1]:
			for j in range(i, i+3):
				if not j in out:
					out.append(j);
	
	return out;

static func detect_in_jagged(jagged_array):
	var out = [];
	var max_height_col = 0;
	
	for col in range(len(jagged_array)):
		for row in detect_in_a_row(jagged_array[col]):
			var vec = Vector2(col, row);
			if not vec in out:
				out.append(vec);
	
	for col in jagged_array:
		max_height_col = max(max_height_col, len(col));
	
	for row in range(max_height_col):
		var contents = [];
		for col in range(len(jagged_array)):
			contents.append(-1 if len(jagged_array[col]) <= row else jagged_array[col][row])
		for col in detect_in_a_row(contents):
			var vec = Vector2(col, row);
			if not vec in out:
				out.append(vec);
	
	return out;