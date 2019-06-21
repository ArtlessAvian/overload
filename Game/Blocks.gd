extends TileMap
# Always belongs to a Board, as its direct child.

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
	for _col in range(get_parent().board_width):
		board.append([]);
		chain_checker.append([])
		new_row.append(-1);
	
	for row in range(get_parent().board_height/2):
		prepend_line(row == 0)
	
	#### handle view
	self.position.x = -get_parent().board_width/2;
	self.position *= self.cell_size; 

func _process(_delta):
	# handle view.
	# yeah it updates every frame, whatever.
	# technically its O(1) :)
	self.clear()
	for col in range(get_parent().board_width):
		for row in range(min(get_parent().board_height, len(board[col]))):
			self.set_cell(col, -row-1, board[col][row]);
		self.set_cell(col, 0, new_row[col]);
	
	self.position.y = get_parent().board_height/2;
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
		if self.pause > 0:
			self.pause -= delta;
		else:
			if (not self.force_raise) and self.get_board().garbage_inbox > 0:
				self.receive_garbage(self.get_board().garbage_inbox);
				self.get_board().garbage_inbox = 0;
			
			if self.has_space():
				if (self.fractional_raise < 1):
					self.fractional_raise += delta * \
						($"..".force_raise_speed if self.force_raise else $"..".rising_speed);
				else:
					self.force_raise = false;
					self.true_raise()
			else:
				self.force_raise = false;
	else:
		self.force_raise = false;


func prepend_line(first = false):
	for i in range(len(board)):
#		var block_index = i + self.line_count * self.get_parent().board_width;
		if (first):
			new_row[i] = randi() % get_parent().color_count;
		board[i].push_front(new_row[i]);
		chain_checker[i].push_front(1);
		self.line_count += 1;
		new_row[i] = randi() % get_parent().color_count;

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
		while not board[i].empty() and board[i].back() == $"..".EMPTY:
			board[i].pop_back();
			chain_checker[i].pop_back();
	# Now there shouldn't be any empty spaces to overcount.
	 
	for array in board:
		if len(array) >= get_parent().board_height:
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
	for y in range(get_parent().board_height): 
		# Build the row
		var row = [];
		for x in range(len(board)):
			if y < len(board[x]):
				row.append(board[x][y]);
			else:
				row.append($"..".EMPTY);
		
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
				self.board[x][y] = $"..".CLEARING;
				exploder.chain = max(exploder.chain, self.chain_checker[x][y]);
				
				# Clear neighboring garbage
				for x_off in range(-1, 2):
					for y_off in range(-1, 2):
						if 0 <= x + x_off and x + x_off < len(board):
							if 0 <= y + y_off and y + y_off < len(board[x+x_off]):
								if (self.board[x+x_off][y+y_off] == $"..".GARBAGE):
									exploder.set_cell(x+x_off, -y-y_off-1, self.board[x+x_off][y+y_off]);
									self.board[x+x_off][y+y_off] = $"..".CLEARING;
						
	exploder.initialize()
	$"..".emit_signal("clear", self.get_board(), exploder.chain, len(exploder.model_explode));
	$Exploders.add_child(exploder);

func make_faller_column(x, y, chain = 1):
	var column = [];
	
	var overhang = false;
	for i in range(y, len(board[x])):
		if board[x][i] in [5, -1]:
			overhang = true;
			break;
		column.append(board[x][i]);
	
	for j in range(len(column)):
		if (overhang):
			board[x][y+j] = -1;
		else:
			board[x].pop_back();
			chain_checker[x].pop_back();
	
	if len(column) == 0:
		return;
	
	var faller = FALLER_SCENE.instance();
	faller.faller_x = x;
	faller.faller_y = y;
	faller.chain = chain;
	faller.blocks = column;
	faller.redraw();
	$"Fallers".add_child(faller);
	$"Fallers".move_child(faller, 0);
	return faller;

func receive_garbage(points):
	var tallest = get_parent().board_height;
	for col in self.board:
		tallest = max(tallest, len(col));
	
	var shuffle = range(len(self.board));
	shuffle.shuffle();
	
	for i in range(min(points, len(self.board))):
		var faller = FALLER_SCENE.instance();
		faller.blocks = [];
		for _j in range(points/len(self.board) + int(i < points % len(self.board))):
			faller.blocks.append($"..".GARBAGE);
		
		faller.faller_x = shuffle.pop_back();
		faller.faller_y = tallest;
		faller.redraw();
		$"Fallers".add_child(faller);
		$"Fallers".move_child(faller, 0);
		faller._physics_process(0);

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
	
	var left_faller = self.make_faller_column(x, y);
	var right_faller = self.make_faller_column(x + 1, y);
	
	# Create empty fallers if null
	if left_faller == null:
		if right_faller == null:
			return;
		left_faller = new_empty_faller(x, y);
	elif right_faller == null:
		right_faller = new_empty_faller(x+1, y)
	
	# Swap the bottom blocks of the two fallers
	if len(left_faller.blocks) > 0:
		if len(right_faller.blocks) > 0:
			var temp = left_faller.blocks[0];
			left_faller.blocks[0] = right_faller.blocks[0];
			right_faller.blocks[0] = temp;
		else:
			right_faller.blocks.append(left_faller.blocks.pop_front());
			left_faller.faller_y += 1;
	else:
		if len(right_faller.blocks) > 0:
			left_faller.blocks.append(right_faller.blocks.pop_front());
			right_faller.faller_y += 1;
		else:
			pass
	
	left_faller.redraw();
	right_faller.redraw();
	
	left_faller._physics_process(0);
	right_faller._physics_process(0);

### Helpers
func in_a_row(array):
	var out = [];
	var what = -1;
	var how_many = 0;
	for item in array:
		if (what != item or what < 0 or what >= $"..".color_count):
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

func new_empty_faller(x, y):
	var faller = FALLER_SCENE.instance();
	faller.faller_x = x;
	faller.faller_y = y;
	$"Fallers".add_child(faller);
	$"Fallers".move_child(faller, 0);
	return faller;

# Parenting
func get_board():
	return self.get_parent();