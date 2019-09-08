extends Node
class_name Blocks
signal clear # Int for Chain, Array of Vector2s of all the positions.

# Jagged Array
var _static_blocks : Array = [];
var _chain_storage : Array = []; # Working in parallel.
var _queued_rows : Array = [[], [], []]; # 3 x Cols Array. Dequeues from the front.

var _queue_check : bool;

func _init(width : int = 6) -> void:
	self.init_width(width);
	self.init_queued_rows();

func _physics_process(delta: float) -> void:
#	if _queue_check:
#		_queue_check = false;
#		check_for_clears();
	pass

# Stuff

func init_width(width):
	while len(_static_blocks) != width:
		_static_blocks.append([]);
		_chain_storage.append([]);
		for row in _queued_rows:
			row.append(-1);

func init_queued_rows():
	for i in range(3):
		self._queued_rows.pop_front();
		self._queued_rows.push_back(queue_new_row());

func queue_new_row():
	var out = [];
	for col in self.get_width():
		out.append(-1);
	
	var shuffle = range(self.get_width());
	shuffle.shuffle();
	for col in shuffle:
		var bans = [];
		
		# Only 3 unique bans possible at a time. Also note that the game then must have 4 colors.
		if col > 1:
			if out[col-2] == out[col-1] and out[col-1] != -1:
				if not out[col-1] in bans:
					bans.append(out[col-1]);
		if col > 0 and col < self.get_width()-1:
			if out[col-1] == out[col+1] and out[col-1] != -1:
				if not out[col-1] in bans:
					bans.append(out[col-1]);
		if col < self.get_width()-2:
			if out[col+1] == out[col+2] and out[col+1] != -1:
				if not out[col+1] in bans:
					bans.append(out[col+1]);
		if _queued_rows[0][col] == _queued_rows[1][col]:
			if not _queued_rows[0][col] in bans:
				bans.append(_queued_rows[0][col]);
		
		out[col] = random_with_bans(6, bans);
	
	return out;

func push_up():
	var popped = self._queued_rows.pop_front();
	for col in range(self.get_width()):
		self._static_blocks[col].push_front(popped[col]);
		self._chain_storage[col].push_front(0);
	self._queued_rows.push_back(queue_new_row());

#func check_for_clears():
#	var clears = detect_in_jagged(_static_blocks);
#	if not clears.empty():
#		var max_chain = 1;
#		for vec in clears:
#			max_chain = max(max_chain, _chain_storage[vec.x][vec.y]);
#		emit_signal("clear", clears)

# Getters with some logic
func get_width():
	return len(_static_blocks);

func get_block(col : int, row : int):
	if len(_static_blocks[col]) <= row:
		return -1;

	if row >= 0:
		return _static_blocks[col][row];
	else:
		return _queued_rows[-1-row][col];
	# Possible OOB with a row thats too low. Hopefully doesn't happen.

# Static Helpers
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

static func random_with_bans(limit : int, banned : Array):
	banned.sort();
	var pick = randi() % (limit - len(banned));
	for ban in banned:
		if pick >= ban:
			pick += 1;
		else:
			break;
	return pick;