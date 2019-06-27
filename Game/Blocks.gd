extends TileMap
signal clear
class_name Blocks

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
	if (Input.is_action_just_pressed("ui_home")):
		self.receive_garbage(20);
	
	if (self.queue_swap != null):
		self.swap(self.queue_swap.x, self.queue_swap.y);
		self.queue_swap = null;
	
	if (self.queue_check):
		self.check();
		self.queue_check = false;
	
	# This could be cleaned up.
	if $"Exploders".get_child_count() == 0 and $Fallers.get_child_count() == 0:
		if self.pause > 0 and not self.force_raise:
			self.pause -= delta;
		else:
#			if (not self.force_raise) and self.get_board().garbage_inbox > 0:
#				self.receive_garbage(self.get_board().garbage_inbox);
#				self.get_board().garbage_inbox = 0;
			
			if self.has_space():
				if (self.fractional_raise < 1):
					self.fractional_raise += delta * \
						(self.board_options.force_raise_speed if self.force_raise else self.board_options.rising_speed);
				else:
					self.force_raise = false;
					self.true_raise()
			else:
				self.force_raise = false;
	else:
		self.force_raise = false;


func prepend_line(first = false):
	for i in range(len(board)):
#		var block_index = i + self.line_count * self.board_options.board_width;
		if (first):
			new_row[i] = randi() % board_options.color_count;
		board[i].push_front(new_row[i]);
		chain_checker[i].push_front(1);
		self.line_count += 1;
		new_row[i] = randi() % board_options.color_count;

func true_raise():
	self.prepend_line();
	self.force_raise = false;
	self.fractional_raise -= 1;

	for child in get_children():
		child.propagate_call("true_raise");
	
	self.check();

func has_space():
	# Pop trailing empty spaces.
	for i in range(len(board)):
		while not board[i].empty() and board[i].back() == self.board_options.EMPTY:
			board[i].pop_back();
			chain_checker[i].pop_back();
	# Now there shouldn't be any empty spaces to overcount.
	 
	for array in board:
		if len(array) >= board_options.board_height:
			return false;
	
	return true

func check():
	var any_clears = false;
	var to_clear = []; # Consider changing to a set
	
	for x in range(len(board)):
		to_clear.append([]);
		var the_spread = spread(in_a_row(board[x]))
		for item in the_spread:
			to_clear[x].append(item >= 3);
			if (item >= 3):
				any_clears = true;

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
				to_clear[x][y] = to_clear[x][y] or the_spread[x] >= 3;
				if (the_spread[x] >= 3):
					any_clears = true;
	
	if (any_clears):
		self.do_clears(to_clear)
		
	for x in range(len(self.chain_checker)):
		for y in range(len(self.chain_checker[x])):
			self.chain_checker[x][y] = 1;

func do_clears(to_clear):
#	self.force_raise = false; # cut short any raising
	
	var exploder = EXPLODER_SCENE.instance();
	for x in range(len(board)):
		for y in range(len(board[x])-1, -1, -1):
			if (to_clear[x][y]):
				exploder.set_cell(x, -y-1, self.board[x][y]);
				self.board[x][y] = self.board_options.CLEARING;
				exploder.chain = max(exploder.chain, self.chain_checker[x][y]);
				
				# Clear neighboring garbage
				for x_off in range(-1, 2):
					for y_off in range(-1, 2):
						if 0 <= x + x_off and x + x_off < len(board):
							if 0 <= y + y_off and y + y_off < len(board[x+x_off]):
								if (self.board[x+x_off][y+y_off] == self.board_options.GARBAGE):
									exploder.set_cell(x+x_off, -y-y_off-1, self.board[x+x_off][y+y_off]);
									self.board[x+x_off][y+y_off] = self.board_options.CLEARING;
						
	exploder.initialize();
	exploder.connect("finished_exploding", self, "_on_Exploder_finished_exploding");
	self.emit_signal("clear", exploder.chain, len(exploder.model_explode));
	$Exploders.add_child(exploder);
	
	# TODO: Better formula
	self.pause = 1;

func make_faller_column(x, y, chain):
	var blocks = pop_column_slice(x, y);
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
#
#	var faller = FALLER_SCENE.instance();
#	faller.construct(x, board[x], chain_checker[x], y, column, chain);
#	faller.connect("finished_falling", self, "_on_Faller_finished_falling");
#	faller.set_board_options(self.board_options);
#	$"Fallers".add_child(faller);
#	$"Fallers".move_child(faller, 0);
#	return faller;

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
	
	var left_empty = len(left_blocks) == 0;
	var right_empty = len(right_blocks) == 0;

	# Swap the bottom blocks of the two fallers
	if left_empty:
		if right_empty:
			return;
		else:
			left_blocks.append(right_blocks.pop_front());
	else:
		if right_empty:
			right_blocks.append(left_blocks.pop_front());
		else:
			var temp = left_blocks[0];
			left_blocks[0] = right_blocks[0];
			right_blocks[0] = temp;
	
	self.add_new_faller(x, y + int(right_empty), left_blocks, 1);
	self.add_new_faller(x+1, y + int(left_empty), right_blocks, 1);

func tallest_column():
	var tallest = 0;
	for col in range(len(board)):
		if len(board[col]) > len(board[tallest]):
			tallest = col;
	return tallest;

func tallest_column_height():
	return len(board[self.tallest_column()]);

### Adding Children With Signals
func add_new_faller(x, y, blocks, chain):
	var faller : Faller = FALLER_SCENE.instance();
	faller.construct(x, self.board[x], self.chain_checker[x], y, blocks, chain);
	self.add_faller(faller);

func add_faller(faller):
	faller.connect("finished_falling", self, "_on_Faller_finished_falling");
	$Fallers.add_child(faller);
#	$"Fallers".move_child(faller, 0);

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

### Helpers
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