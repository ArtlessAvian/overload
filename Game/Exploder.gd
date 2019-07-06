extends TileMap

signal finished_exploding; # Args are an array of Vector2 (Ints), then a y offset.
class_name Exploder

# TODO: Set cell size for everything that gets board_options set.
# Always a child of a child of Blocks
var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;
#	self.cell_size = self.board_options.cell_size;

###################################################################
# As long as this object lives, the blocks it holds are the "CLEARING" tile.
# As soon as this object dies, the blocks are replaced with the "EMPTY" tile (or a regular block).
class ExploderRAII:
	extends Object
	var board_options : BoardOptions;
	var to_explode : Array;
	var to_explode_into : Array;
	var board : Array;
	var y_offset = 0;
	
	func _init(board_options : BoardOptions, board, to_explode):
		self.board_options = board_options;
		self.to_explode = to_explode;
		self.to_explode_into = [];
		self.board = board;
		for vec in to_explode:
			if board[vec.x][vec.y] == board_options.GARBAGE:
				to_explode_into.append(randi() % self.board_options.color_count);
			else:
				to_explode_into.append(self.board_options.EMPTY);
			board[vec.x][vec.y] = board_options.CLEARING;
	
	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			for i in range(len(to_explode)):
				var vec = to_explode[i];
				assert(self.board[vec.x][vec.y + y_offset] == board_options.CLEARING);
				self.board[vec.x][vec.y + y_offset] = self.to_explode_into[i];

###################################################################

# Model
var physics_time : float = 0;
var exploder_raii : ExploderRAII;
var chain = 1;

# View
var linger_time : float = 1;
var animation_time : float = 0;

func construct(board_options : BoardOptions, board : Array, to_explode : Array, chain : int):
	self.set_board_options(board_options);
	
	for vec in to_explode:
		self.set_cell(vec.x, -vec.y-1, board[vec.x][vec.y]);
	
	self.exploder_raii = ExploderRAII.new(board_options, board, to_explode);
	self.chain = chain;
	
	# Children stuff
	
	var combo = len(self.exploder_raii.to_explode);
	if (chain != 1):
		$"ClearPopup/Chain/Label".text = "x" + str(chain);
	else:
		$"ClearPopup/Chain".free()
	if (combo > 3):
		$"ClearPopup/Combo/Label".text = str(combo);
	else:
		$"ClearPopup/Combo".free()
	$"ClearPopup".rect_position = self.map_to_world(self.exploder_raii.to_explode[0]) + self.cell_size/2;
	$"ClearPopup".rect_position.y *= -1;
	$"ClearPopup".rect_position -= $"ClearPopup".rect_size / 2;

func is_model_relevant():
	return self.exploder_raii != null;

func lifespan():
	return self.board_options.explode_pause + self.board_options.explode_interval * len(self.exploder_raii.to_explode);

func _physics_process(delta):
	if not self.is_model_relevant():
		return;
	
	self.physics_time += delta;
	if self.physics_time >= self.lifespan():
		var to_explode = self.exploder_raii.to_explode;
		var y_offset = self.exploder_raii.y_offset;
		
		self.exploder_raii.free();
		self.exploder_raii = null;
		
		self.emit_signal("finished_exploding", to_explode, y_offset, self.chain);
		
		# Finish up visually too, ig
		self.clear();

func num_exploded_blocks(t : float):
	var val = ceil((t - self.board_options.explode_pause/2)/self.board_options.explode_interval);
	return clamp(val, 0, len(self.exploder_raii.to_explode));

func _process(delta):
	self.animation_time += delta;
	
	if not self.is_model_relevant():
		self.linger_time -= delta;
		if self.linger_time <= 0:
			self.queue_free();
	else:
		for i in range(self.num_exploded_blocks(self.animation_time - delta), self.num_exploded_blocks(self.animation_time)):
			var vec = exploder_raii.to_explode[i];
			var color = exploder_raii.to_explode_into[i];
			self.set_cell(vec.x, -vec.y-1, color);
			
			var dupe = $Particles2D.duplicate();
			dupe.position = self.map_to_world(vec) + self.cell_size/2;
			dupe.position.y *= -1;
			dupe.emitting = true;
			dupe.get_node("AudioStreamPlayer2D").pitch_scale = pow(1.0595, i + chain);
			dupe.get_node("AudioStreamPlayer2D").play();
			self.add_child(dupe);
	
	# Magic numbers, but they look nice.
#	$ClearPopup.rect_position.y -= 15 * max(0, 0.3 - self.animation_time);
#	$ClearPopup.modulate.a = 1 - self.animation_time;
	
	$ClearPopup.rect_position.y -= 4 * (0.5 - self.animation_time);
	$ClearPopup.modulate.a = 1 - pow(self.animation_time/1.5, 2);

func true_raise():
	if (self.exploder_raii != null):
		self.exploder_raii.y_offset += 1;
	self.position.y -= self.cell_size.y;