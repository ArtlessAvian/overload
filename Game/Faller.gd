extends TileMap
signal finished_falling;
class_name Faller

var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

# Fallers are groups of blocks traveling together.
# While falling, they may not be swapped. No bullshitting with that lmao.
# Theres no hovering like in a certain other game, for simplicity.
# Fallers cannot land on fallers, thankfully.

var x : int;
var y_offset : float;
var column : Array;
var column_chainer : Array;
var blocks : Array;
var chain : int;

func construct(x : int, column : Array, column_chainer : Array, y : int, blocks : Array, chain : int):
	self.x = x;
	self.column = column;
	self.column_chainer = column_chainer;
	self.y_offset = y;
	self.blocks = blocks;
	self.chain = chain;
	
	assert(len(self.get_used_cells()) == 0);
	
	for j in len(blocks):
		assert(blocks[j] != 5);
		self.set_cell(0, -j-1, blocks[j]);

func _process(_delta):
	self.position.x = self.x;
	self.position.y = self.y_offset;
	self.position *= self.cell_size;
	self.position.y *= -1;

func _physics_process(delta):
	self.y_offset -= delta * self.board_options.faller_speed;
	
	# Check for a possible collision
	if self.y_offset <= len(self.column):
		# Check that the colliding "tile" isn't empty space.
		# There is a possibility that the faller could tunnel
		# through a whole set of blocks and into some empty section,
		# but thats not likely, right?
		# warning-ignore:narrowing_conversion
		var y_index : int = max(0, ceil(self.y_offset));
		
		if (y_index == 0) or (self.column[y_index - 1] != self.board_options.EMPTY):
			# March upwards in case of tunneling
			while (y_index < len(self.column)) and (self.column[y_index] != self.board_options.EMPTY):
				y_index += 1;
			
			# Copy blocks into the column
			for offset in range(len(blocks)):
				if y_index + offset >= len(column):
					self.column.append(blocks[offset])
					self.column_chainer.append(chain);
				else:
					assert(column[y_index + offset] == self.board_options.EMPTY);
					self.column[y_index + offset] = blocks[offset];
					self.column_chainer[y_index + offset] = chain;
					
			# Finish up
			self.emit_signal("finished_falling");
			self.queue_free();

func intersects(x : int, y : int) -> bool:
	if x != self.x:
		return false;
	if y < floor(self.y_offset):
		return false;
	if y > floor(self.y_offset) + len(blocks):
		return false;
	return true;

func true_raise():
	self.y_offset += 1;