extends TileMap
signal clear
class_name Blocks

# TODO: Has too much responsibility. Don't know if thats good or not.

# Always belongs to a Board, as its direct child.
var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

# Model
const FALLER_SCENE = preload("res://Game/Faller.tscn");
const EXPLODER_SCENE = preload("res://Game/Exploder.tscn");

var board = []; # outer array is the column. inner array is the row.
var new_row = [];
var chain_checker = [] # should act in parallel with the board.
var queue_check = false;

var force_raise = false;
var fractional_raise = 0;
var line_count = 0;

var queue_swap = null;
var pause = 0; # from clearing, or stun from receiving garbage.

func _ready():
	#### handle model
	for _col in range(board_options.board_width):
		board.append([]);
		chain_checker.append([])
		new_row.append(-1);
	
	for row in range(board_options.board_height/2):
		prepend_line(row == 0)
	
	#### handle view
	self.position.x = -board_options.board_width/2;
	self.position *= self.cell_size; 

func _process(_delta):
	# handle view.
	# yeah it updates every frame, whatever.
	# technically its O(1) :)
	self.clear()
	for col in range(board_options.board_width):
		for row in range(min(board_options.board_height, len(board[col]))):
			self.set_cell(col, -row-1, board[col][row]);
		self.set_cell(col, 0, new_row[col]);
	
	self.position.y = board_options.board_height/2;
	self.position.y -= min(1, self.fractional_raise);
	self.position.y *= self.cell_size.y;

func _physics_process(delta):
	if (self.queue_swap != null):
		self.swap(self.queue_swap.x, self.queue_swap.y);
		self.queue_swap = null;
	
	if (self.queue_check):
		self.check();
		self.queue_check = false;
	
	self.process_raise(delta);

### Raising the board

func process_raise(delta):
	if self.pause > 0 and not self.any_exploder_active():
		self.pause -= delta;
	
	if not self.has_space():
		self.force_raise = false;
		return;
	
	if not self.force_raise:
		if self.any_exploder_active():
			return;
		elif self.pause > 0:
			return;
	 
	# Finally raise the board.
	self.fractional_raise += delta * \
			(self.board_options.force_raise_speed if self.force_raise else self.board_options.rising_speed);
	if (self.fractional_raise >= 1):
		self.true_raise();
		self.force_raise = false;

func prepend_line(first = false):
	for i in range(len(board)):
#		var block_index = i + self.line_count * self.board_options.board_width;
		if (first):
			new_row[i] = randi() % board_options.color_count;
		
		board[i].push_front(new_row[i]);
		chain_checker[i].push_front(1);
		self.line_count += 1;
		
		# Generate a color that isn't the same as the one above.
#		var new = randi() % (board_options.color_count - 1);
#		new_row[i] = new + int(new >= new_row[i]);
		new_row[i] = randi() % board_options.color_count;
		
func true_raise():
	self.prepend_line();
	self.force_raise = false;
	self.fractional_raise -= 1;

	for child in get_children():
		child.propagate_call("true_raise");
	
	self.check();

### Clearing the board

func check():
	var to_clear = []; # Will act like a set
	
	for x in range(len(board)):
		var the_spread = spread(in_a_row(board[x]))
		for y in range(len(the_spread)):
			if (the_spread[y] >= 3):
				to_clear.append(Vector2(x, y));

	# Assumes there isn't anything to check above the board.
	for y in range(board_options.board_height): 
		# Build the row
		var row = [];
		for x in range(len(board)):
			if y < len(board[x]):
				row.append(board[x][y]);
			else:
				row.append(self.board_options.EMPTY);
		
		# Check the row
		var the_spread = spread(in_a_row(row));
		for x in range(len(board)):
			if y < len(board[x]):
				if (the_spread[x] >= 3) and (not Vector2(x, y) in to_clear):
					to_clear.append(Vector2(x, y));
	
	if (not to_clear.empty()):
		self.do_clears(to_clear)
		
	for x in range(len(self.chain_checker)):
		for y in range(len(self.chain_checker[x])):
			self.chain_checker[x][y] = 1;

static func clear_sorter(a, b):
	if a.y == b.y:
		return a.x < b.x;
	return a.y > b.y;

func do_clears(to_clear : Array):
	self.force_raise = false; # cut short any raising
	var chain = 1;
	
	to_clear.sort_custom(self, "clear_sorter");
	
	for vec in to_clear:
#			to_explode.append(Vector2(x, y));
#				exploder.set_cell(x, -y-1, self.board[x][y]);
#				self.board[x][y] = self.board_options.CLEARING;
		chain = max(chain, self.chain_checker[vec.x][vec.y]);
#
#				# Clear neighboring garbage
#				for x_off in range(-1, 2):
#					for y_off in range(-1, 2):
#						if 0 <= x + x_off and x + x_off < len(board):
#							if 0 <= y + y_off and y + y_off < len(board[x+x_off]):
#								if (self.board[x+x_off][y+y_off] == self.board_options.GARBAGE):
#									exploder.set_cell(x+x_off, -y-y_off-1, self.board[x+x_off][y+y_off]);
#									self.board[x+x_off][y+y_off] = self.board_options.CLEARING;
#
	self.add_new_exploder(to_clear, chain);
	self.emit_signal("clear", chain, len(to_clear));
	
	# TODO: Better formula
	self.pause = 1;

### Swapping blocks

func swap(x, y):
	# Prevent swapping with clearing blocks
	if y < len(self.board[x]):
		if self.board[x][y] == 5:
			return;
	if y < len(self.board[x+1]):
		if self.board[x+1][y] == 5:
			return;

	# Prevent swapping into a faller
	for faller in $"Fallers".get_children():
		if faller.intersects(x, y) or faller.intersects(x+1, y):
			return;

	# TODO: Rewrite to create fallers at the end >:(
	var left_blocks = self.pop_column_slice(x, y);
	var right_blocks = self.pop_column_slice(x + 1, y);
	
	var left_was_empty = left_blocks.empty();
	var right_was_empty = right_blocks.empty();

	# Swap the bottom blocks of the two fallers
	if left_was_empty:
		if right_was_empty:
			return;
		else:
			left_blocks.append(right_blocks.pop_front());
	else:
		if right_was_empty:
			right_blocks.append(left_blocks.pop_front());
		else:
			var temp = left_blocks[0];
			left_blocks[0] = right_blocks[0];
			right_blocks[0] = temp;
	
	if (not left_blocks.empty()):
		self.add_new_faller(x, y + int(right_was_empty), left_blocks, 1);
	if (not right_blocks.empty()):
		self.add_new_faller(x+1, y + int(left_was_empty), right_blocks, 1);

### Garbage Receiving

func receive_garbage(points):
	var tallest = board_options.board_height;
	for col in self.board:
		tallest = max(tallest, len(col));
	
	var shuffle = range(len(self.board));
	shuffle.shuffle();
	
	for i in range(min(points, len(self.board))):
		var blocks = [];
		for _j in range(points/len(self.board) + int(i < points % len(self.board))):
			blocks.append(self.board_options.GARBAGE);
		
		var column_index = shuffle.pop_back();
		
		self.add_new_faller(column_index, tallest, blocks, 1);

### Common Functions and Helpers

func any_exploder_active():
	# any(exploder.is_model_relevant() for exploder in $Exploders.get_children())
	for exploder in $Exploders.get_children():
		if exploder.is_model_relevant():
			return true
	return false

func has_space():
	return tallest_column_height() < self.board_options.board_height;

func tallest_column_height():
	return len(board[self.tallest_column()]);

func tallest_column():
	self.pop_trailing_empty();
	var tallest = 0;
	for col in range(len(board)):
		if len(board[col]) > len(board[tallest]):
			tallest = col;
	return tallest;

func pop_trailing_empty():
	for i in range(len(board)):
		while not board[i].empty() and board[i].back() == self.board_options.EMPTY:
			board[i].pop_back();
			chain_checker[i].pop_back();

func make_faller_column(x, y, chain):
	var blocks = pop_column_slice(x, y);
	if (blocks != []):
		self.add_new_faller(x, y, blocks, chain);

func pop_column_slice(x, y):
	var column = [];
	
	var overhang = false;
	for i in range(y, len(board[x])):
		if board[x][i] in [5, -1, 7]:
			overhang = true;
			break;
		column.append(board[x][i]);
	
	for j in range(len(column)):
		if (overhang):
			board[x][y+j] = self.board_options.EMPTY;
		else:
			board[x].pop_back();
			chain_checker[x].pop_back();
	
	return column;

func in_a_row(array):
	var out = [];
	var what = -1;
	var how_many = 0;
	for item in array:
		if (what != item or what < 0 or what >= self.board_options.color_count):
			what = item;
			how_many = 1;
		else:
			how_many += 1;
		out.append(how_many)
	return out;

func spread(array):
	var out = [];
	for i in range(len(array)):
		if (i == len(array)-1 or array[i] >= array[i+1]):
			for _j in range(array[i]):
				out.append(array[i]);
	return out;

### Adding Children With Signals
func add_new_faller(x : int, y : float, blocks : Array, chain : int):
	var faller : Faller = FALLER_SCENE.instance();
	faller.construct(self.board_options, x, self.board[x], self.chain_checker[x], y, blocks, chain);
	self.add_faller(faller);

func add_faller(faller : Faller):
	faller.connect("finished_falling", self, "_on_Faller_finished_falling");
	$Fallers.add_child(faller);
#	$"Fallers".move_child(faller, 0);

func add_new_exploder(to_explode : Array, chain):
	var exploder : Exploder = EXPLODER_SCENE.instance();
	exploder.construct(self.board_options, self.board, to_explode, chain);
	self.add_exploder(exploder);

func add_exploder(exploder : Exploder):
	exploder.connect("finished_exploding", self, "_on_Exploder_finished_exploding");
	$Exploders.add_child(exploder);

### Children's Signals
func _on_Cursor_raise():
	if self.is_physics_processing():
		self.force_raise = true;

func _on_Cursor_swap(vec):
	if self.is_physics_processing():
		self.queue_swap = vec;

func _on_Faller_finished_falling():
	self.queue_check = true;

func _on_Exploder_finished_exploding(block_locs, y_offset, chain):
	for loc in block_locs:
		var y = loc.y + y_offset;
		self.board[loc.x][y] = self.board_options.EMPTY;
		self.make_faller_column(loc.x, y + 1, chain + 1);
	
	for i in range(len(board)):
		while not board[i].empty() and board[i].back() == self.board_options.EMPTY:
			board[i].pop_back();
			chain_checker[i].pop_back();
