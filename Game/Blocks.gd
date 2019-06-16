extends TileMap
# Always belongs to a board, as a direct child.

# Model
const faller_scene = preload("res://Game/Faller.tscn");
const exploder_scene = preload("res://Game/Exploder.tscn");
const explode_pause = 0.5;
const explode_frequency = 0.1;

var board = []; # outer array is the column. inner array is the row.
var chain_checker = [] # matches board.
var new_row = [];
var should_check = false;
#var next_clear_id = 0;
#var clearing = []; # id blocks to clearing groups
#var finish_clearing = []; # ids of blocks to cause fallers

var raise = false;
var fractional_raise = 0;
var visual_shake = 0; # in pixels

# Called when the node enters the scene tree for the first time.
func _ready():
	#### handle model
	for col in range(get_parent().board_width):
		board.append([]);
#		clearing.append([]);
		for row in range(get_parent().board_height/2):
			board[col].append(randi() % get_parent().color_count)
		new_row.append(randi() % get_parent().color_count)

	# Mirror the board
	for col in range(len(board)):
		chain_checker.append([])
		for row in range(len(board[col])):
			chain_checker[col].append(1);
		
#	board[5][7] = -1;
	
	#### handle view
	# position everything
	self.position.x = -get_parent().board_width/2;
#	self.position.y = get_parent().board_height/2;
	self.position *= self.cell_size; 
#	$Cursor.position = self.cursor_pos;
#	$Cursor.position *= self.cell_size;
#	$Cursor.position.y *= -1;

func _process(delta):
	# handle view.
	# yeah it updates every frame, whatever.
	self.clear()
	for col in range(get_parent().board_width):
		for row in range(min(get_parent().board_height, len(board[col]))):
			self.set_cell(col, -row-1, board[col][row]);
		self.set_cell(col, 0, new_row[col]);
	
	self.position.y = get_parent().board_height/2;
	self.position.y -= min(1, self.fractional_raise);
	self.position.y *= self.cell_size.y;
#	self.position.y += self.visual_shake;
	
	$Cursor.position = $Cursor.cursor_pos;
	$Cursor.position += $Cursor.DRAW_OFFSET;
	$Cursor.position *= self.cell_size;
	$Cursor.position.y *= -1;

	for faller in $"Fallers".get_children():
		faller.position.y = faller.faller_y
		faller.position.y *= self.cell_size.y;
		faller.position.y *= -1;
	for exploder in $"Exploders".get_children():
#		exploder.position.x += 10 * (randf() - 0.5);
#		exploder.position.y += 10 * (randf() - 0.5);
		exploder.position.y = exploder.y_offset;
		exploder.position.y *= self.cell_size.y;
		exploder.position.y *= -1;
		pass

func _physics_process(delta):
	if (Input.is_action_just_pressed("ui_home")):
		self.receive_garbage(20);
	
	if (should_check):
		self.check();
		should_check = false;
	
#	for x in range(len(clearing)):
#		for y in range(len(clearing[x])-1, -1, -1):
#			if (clearing[x][y] in finish_clearing):
#				self.make_faller_column(x, y+1);
#				self.board[x].remove(y);
#	finish_clearing.clear();
	
	if (self.fractional_raise < 1):
		if ($"Exploders".get_child_count() == 0 and self.has_space()):
			if raise:
				self.fractional_raise += delta * 5;
			else:
				self.fractional_raise += delta * $"..".rising_speed;
		else:
			self.raise = false;
	else: #(self.fractional_raise >= 1):
		if (self.has_space()):
			self.true_raise()
		else:
			pass

func true_raise():
#	for col in clearing:
#		col.pop_back();
#		col.push_front(-1);

	for i in range(len(board)):
		board[i].push_front(new_row[i]);
		chain_checker[i].push_front(1);
		new_row[i] = randi() % get_parent().color_count;
	
	self.raise = false;
	self.fractional_raise -= 1;
	
	# Would do self, but then that recurs.
	for child in get_children():
		child.propagate_call("true_raise");
	
	self.check();

func has_space():
	for i in range(len(board)):
		for dummy in range(len(board[i])):
			if board[i].back() == $"..".EMPTY:
				board[i].pop_back();
				chain_checker[i].pop_back();
			else:
				break;
	
	for array in board:
		if len(array) >= get_parent().board_height:
			return false;
	for faller in $"Fallers".get_children():
		if floor(faller.faller_y) + len(faller.blocks) >= get_parent().board_height:
			return false;
	
	return true

func check():
	var any_clears = false;
	var to_clear = [];
	for x in range(len(board)):
		to_clear.append([]);
		var the_spread = spread(in_a_row(board[x]))
		for item in the_spread:
			to_clear[x].append(item >= 3);
			if (item >= 3):
				any_clears = true;

	for y in range(get_parent().board_height):
		var row = [];
		for x in range(len(board)):
			if y < len(board[x]):
				row.append(board[x][y]);
			else:
				row.append($"..".EMPTY);
		var the_spread = spread(in_a_row(row));
		for x in range(len(board)):
			if y < len(board[x]):
				to_clear[x][y] = to_clear[x][y] or the_spread[x] >= 3;
				if (the_spread[x] >= 3):
					any_clears = true;
	
	if (any_clears):
#		self.next_clear_id += 1;
		var exploder = exploder_scene.instance();
#		exploder.exploder_id = self.next_clear_id;
		for x in range(len(board)):
			for y in range(len(board[x])-1, -1, -1):
				if (to_clear[x][y]):
#					self.clearing[x][y] = self.next_clear_id;
					exploder.set_cell(x, -y-1, self.board[x][y]);
					self.board[x][y] = $"..".CLEARING;
					exploder.chain = max(exploder.chain, self.chain_checker[x][y]);
	#				self.make_faller_column(x, y+1);
	#				self.board[x].pop_back();
					
					# Clear neighboring garbage
					for x_off in range(-1, 2):
						for y_off in range(-1, 2):
							if 0 <= x + x_off and x + x_off < len(board):
								if 0 <= y + y_off and y + y_off < len(board[x+x_off]):
									if (self.board[x+x_off][y+y_off] == $"..".GARBAGE):
										exploder.set_cell(x+x_off, -y-y_off-1, self.board[x+x_off][y+y_off]);
										self.board[x+x_off][y+y_off] = $"..".CLEARING;
							
		exploder.initialize()
#		print(exploder.position);
		$Exploders.add_child(exploder);
	
	for x in range(len(self.chain_checker)):
		for y in range(len(self.chain_checker[x])):
			self.chain_checker[x][y] = 1;

func make_faller_column(x, y, chain = 1):
	var column = [];
	
	var overhang = false;
	for i in range(y, len(board[x])):
		if board[x][i] in [5, -1]:
			overhang = true;
			break;
		column.append(board[x][i]);
	
#	print(x, column)
	for j in range(len(column)):
		if (overhang):
			board[x][y+j] = -1;
#			print("helloooo");
		else:
			board[x].pop_back();
			chain_checker[x].pop_back();
	
	if len(column) == 0:
		return;
	
	var faller = faller_scene.instance();
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
		var faller = faller_scene.instance();
		faller.blocks = [];
		for j in range(points/len(self.board) + int(i < points % len(self.board))):
			faller.blocks.append($"..".GARBAGE);
		
		faller.faller_x = shuffle.pop_back();
		faller.faller_y = tallest;
		faller.redraw();
		$"Fallers".add_child(faller);
		$"Fallers".move_child(faller, 0);
		faller._physics_process(0);

### Cursor Movement


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
		left_faller = faller_scene.instance();
		left_faller.faller_x = x;
		left_faller.faller_y = y;
		$"Fallers".add_child(left_faller);
		$"Fallers".move_child(left_faller, 0);
	if right_faller == null:
		right_faller = faller_scene.instance();
		right_faller.faller_x = x + 1;
		right_faller.faller_y = y;
		$"Fallers".add_child(right_faller);
		$"Fallers".move_child(right_faller, 0);
	
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
			for j in range(array[i]):
				out.append(array[i]);
	return out;
