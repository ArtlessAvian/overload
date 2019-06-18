extends TileMap
# Always a child of a child of Blocks.

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

func _process(_delta):
	self.position.y = self.faller_y
	self.position.y *= self.get_blocks().cell_size.y;
	self.position.y *= -1;

func _physics_process(delta):
#	if len(blocks) == 0:
#		self.queue_free();
#		return;
	
	faller_y -= delta * self.get_board().faller_speed;
	# Collide
	var column = self.get_blocks().board[faller_x];
	if faller_y <= len(column):
		if ceil(faller_y) - 1 < 0 or column[ceil(faller_y) - 1] != $"../../..".EMPTY:
			# Has colldied
			place_in_column(ceil(faller_y));
			# Cleanup and destroy
			self.get_blocks().queue_check = true;
#			get_parent().remove_child(self);
			self.queue_free();

func place_in_column(y):
	var column = $"../..".board[faller_x];
	var chain_column = $"../..".chain_checker[faller_x];
	# Adjust the Y value
	
	y = max(y, 0); # oof
	
	# There is a possibility that the faller could tunnel so hard
	# that it passes through a whole set of blocks and into some empty section. 
	while (y < len(column)) and (column[y] != self.get_board().EMPTY):
		# March upwards
		y += 1;
	
	for index in range(len(blocks)):
		if y + index >= len(column):
			column.append(blocks[index])
			chain_column.append(chain);
		else:
			assert(column[y + index] == self.get_board().EMPTY);
			column[y + index] = blocks[index];
			chain_column[y + index] = chain;

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
	
# Parents:
func get_blocks():
	return $"../..";

func get_board():
	return $"../../..";