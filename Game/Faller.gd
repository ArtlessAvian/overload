extends TileMap
# Fallers are groups of blocks traveling together.
# While falling, they may not be swapped. No bullshitting with that lmao.
# Theres no hovering like in a certain other game, for simplicity.
# Fallers cannot land on fallers, thankfully.

var faller_y = 12;
var faller_x = 0;
var blocks = [];
var chain = 1;

func redraw():
	self.clear();
	for j in len(blocks):
		self.set_cell(faller_x, -j-1, blocks[j]);
		assert(blocks[j] != 5);

func _physics_process(delta):
#	if len(blocks) == 0:
#		self.queue_free();
#		return;
	
	faller_y -= delta * $"../../..".faller_speed;
	# Collide
	var column = $"../..".board[faller_x];
	if faller_y <= len(column):
#		if true:
		if ceil(faller_y) - 1 < 0 or column[ceil(faller_y) - 1] != -1: # if the below tile is not an overhang, keep going.
#			while (ceil(faller_y) < len(column) and not column[ceil(faller_y)-1] in [5, -1]):
#				faller_y += 1;

			var chain_column = $"../..".chain_checker[faller_x];
			for y in range(len(blocks)):
				if ceil(faller_y + y) >= len(column):
					column.append(blocks[y])
					chain_column.append(chain);
				else:
					column[ceil(faller_y + y)] = blocks[y];
					chain_column[ceil(faller_y+y)] = chain;
#		if faller_y < 0 or (column[floor(faller_y)] != -1):
#			# Walk up until a -1 or the end of the array is found.
#			var insertion = max(0,floor(faller_y));
#			while insertion != len(column) and column[insertion] == -1:
#				insertion += 1;
#			# Add to the board, then remove 
#			if insertion == len(column):
#				for y in range(len(blocks)):
#					column.append(blocks[y]);
#			else:
#				for y in range(len(blocks)):
#					column[y + insertion] = blocks[y];
#			while column.back() == 5:
#				column.pop_back();
			$"../..".should_check = true;
			get_parent().remove_child(self);
			self.queue_free()

func intersects(x, y):
	if x != self.faller_x:
		return false;
	if y < floor(self.faller_y):
		return false;
	if y > floor(self.faller_y) + len(blocks):
		return false;
	return true;

func true_raise():
	faller_y += 1;