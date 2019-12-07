extends Node
class_name Blocks
signal clear # Array of Vector2s of all the positions, Int for Chain.

const SPECIAL_BLOCKS : Array = [-1, -2];
const CANNOT_SWITCH : Array = [-2];
const NUM_COLORS : int = 5;

# Jagged Array
var _static_blocks : Array = [];
var _chain_storage : Array = []; # Working in parallel.
var _queued_rows : Array = [[], [], []]; # 3 x Cols Array. Dequeues from the front.

var _queue_check : bool;

func _init(width : int = 6) -> void:
	self.init_width(width);
	self.init_queued_rows();

func _physics_process(delta: float) -> void:
	if _queue_check:
		_queue_check = false;
		check_for_clears();

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
		
		out[col] = random_with_bans(NUM_COLORS, bans);
	
	return out;

func propagate_raise():
	propagate_call("on_board_raise");
	on_board_raise();

func on_board_raise():
	var popped = self._queued_rows.pop_front();
	for col in range(self.get_width()):
		self._static_blocks[col].push_front(popped[col]);
		self._chain_storage[col].push_front(1);
	self._queued_rows.push_back(queue_new_row());

	_queue_check = true;

# warning-ignore-all:narrowing_conversion
func swap(where : Vector2):
	if get_block(where.x, where.y) in CANNOT_SWITCH:
		return;
	if get_block(where.x + 1, where.y) in CANNOT_SWITCH:
		return;
		
	var temp : int = get_block(where.x, where.y);
	set_block(where.x, where.y, get_block(where.x+1, where.y));
	set_block(where.x+1, where.y, temp);
	
	if get_block(where.x, where.y) == -1:
		do_fall(where + Vector2.DOWN, 1);
		do_fall(where + Vector2.RIGHT, 1);
	if get_block(where.x+1, where.y) == -1:
		do_fall(where, 1);
		do_fall(where + Vector2.ONE, 1);
	
	_queue_check = true;

func check_for_clears():
	var clears = detect_in_jagged(_static_blocks);
	if not clears.empty():
		var max_chain = 1;
		for vec in clears:
			max_chain = max(max_chain, _chain_storage[vec.x][vec.y]);
		emit_signal("clear", clears, max_chain);
#		print(clears, max_chain)
		do_clears(clears, max_chain);

	for col in range(len(_chain_storage)):
		for row in range(len(_chain_storage[col])):
			if not Vector2(col, row) in clears:
				_chain_storage[col][row] = 1;

func do_clears(clears : Array, chain : int):
	# Override me!
	for clear in clears:
		set_block(clear.x, clear.y, -1);
	
	for clear in clears:
		do_fall(clear, chain);

func do_fall(where : Vector2, chain : int):
	for i in range(where.y+1, len(_static_blocks[where.x])):
		_chain_storage[where.x][i] = chain + 1;
	
	for i in range(_static_blocks[where.x].count(-1)):
		var y = _static_blocks[where.x].find_last(-1);
		_chain_storage[where.x].remove(y);
		_static_blocks[where.x].remove(y);

	_queue_check = true;

# Getters and Setters with some logic
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

func is_settled() -> bool:
	return not _queue_check;

func set_block(col : int, row : int, to : int):
	while len(_static_blocks[col]) <= row:
		_static_blocks[col].append(-1);
		_chain_storage[col].append(1);
	_static_blocks[col][row] = to;

# Debug
func column_to_string(col : int) -> String:
	var out = "";
	for item in _static_blocks[col]:
		out += str(item);
	return out;

func to_string() -> String:
	var out = "";
	
	for col in range(len(_static_blocks)):
		out += "Row " + str(col) + ": ";
		out += column_to_string(col);
		out += "\n";
	return out.trim_suffix("\n");

# Static Helpers
static func detect_in_a_row(row):
	var out = []
	
	var doubles = [];
	for i in range(0, len(row)-1):
		doubles.append(row[i] == row[i+1] and (not row[i] in SPECIAL_BLOCKS));
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
			contents.append(-1 if len(jagged_array[col]) <= row else jagged_array[col][row]);
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