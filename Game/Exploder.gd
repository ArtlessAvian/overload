extends TileMap

#warning-ignore-all:unused_signal
#warning-ignore-all:unused_class_variable

signal finished_exploding; # Args are an array of Vector2 (Ints), then a y offset.
class_name Exploder

# Always a child of a child of Blocks
var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

###################################################################
# As long as this object lives, the blocks it holds are the "CLEARING" tile.
# As soon as this object dies, the blocks are replaced with the "EMPTY" tile (or a regular block).
class ExploderRAII:
	signal finished_exploding; # Sends itself to a board
	
	var board_options : BoardOptions;
	var to_explode : Array;
	var to_explode_into : Array;
	var board : Array;
	var y_offset = 0;
	
	func _init(board_options : BoardOptions, board, to_explode):
		self.board_options = board_options;
		self.to_explode = to_explode;
		self.board = board;
		for i in range(len(to_explode)):
			var vec = to_explode[i];
			if board[vec.x][vec.y] == board_options.GARBAGE:
				to_explode_into.append(randi() % self.board_options.color_count);
			else:
				to_explode_into.append(self.board_options.EMPTY);
			board[vec.x][vec.y] = board_options.CLEARING;
	
	func free():
		for i in range(len(to_explode)):
			var vec = to_explode[i];
			assert(self.board[vec.x][vec.y + y_offset] == board_options.CLEARING);
			self.board[vec.x][vec.y + y_offset] = self.to_explode_into[i];
		self.emit_signal("finished_exploding", to_explode, y_offset);
		.free();

###################################################################

# Model
var physics_time : float = 0;
var exploder_raii : ExploderRAII;
var chain = 1;

# View
var animation_time : float = 0;

func construct(board_options : BoardOptions, board : Array, to_explode : Array, chain : int):
	self.set_board_options(board_options);
	
	for vec in to_explode:
		self.set_cell(vec.x, -vec.y-1, board[vec.x][vec.y]);
	
	self.exploder_raii = ExploderRAII.new(board_options, board, to_explode);
	self.chain = chain;

func is_model_relevant():
	return self.exploder_raii != null;

func _physics_process(delta):
	if not self.is_model_relevant():
		return;
	
	self.physics_time += delta;
	if self.physics_time >= (self.board_options.explode_pause + self.board_options.explode_interval * len(self.exploder_raii.to_explode)):
		var to_explode = self.exploder_raii.to_explode;
		var y_offset = self.exploder_raii.y_offset;
		
		# Can't free a reference, but...
		self.exploder_raii = null;
		
		self.emit_signal("finished_exploding", to_explode, y_offset, self.chain);

#func point_slope_madness(t : float):
#	return max(0, min(len(

func _process(delta):
	self.animation_time += delta;

func true_raise():
	if (self.exploder_raii != null):
		self.exploder_raii.y_offset += 1;