extends Blocks
class_name DynamicBlocks
signal new_exploder; # Exploder Model
signal new_faller; # Faller Model

const EXPLODER_SCRIPT = preload("res://board/dynamic_blocks/exploder/ExploderModel.gd");
const FALLER_SCRIPT = preload("res://board/dynamic_blocks/faller/FallerModel.gd");

var _exploders : Array = [];
var _fallers : Array = [];

func _init(width : int = 6) -> void:
	._init(width);

func swap(where : Vector2):
	for faller in _fallers:
		if faller._x == where.x or faller._x == where.x+1:
			if floor(faller._y) <= where.y and where.y <= floor(faller._y + len(faller._slice)):
				return;
	
	.swap(where);

func do_clears(clears : Array, max_chain : int):
	var exploder : Exploder = EXPLODER_SCRIPT.new(clears, _static_blocks, max_chain);
	self.add_child(exploder);
	_exploders.append(exploder);
	exploder.connect("done_exploding", self, "on_Exploder_done_exploding");
	self.emit_signal("new_exploder", exploder);

func on_Exploder_done_exploding(exploder, clears, colors, chain):
	_exploders.erase(exploder);
	clean_trailing_empty();
	# Reverse order for descending y.
	for i in range(len(clears)-1, -1, -1):
		do_fall(clears[i] + Vector2.DOWN, chain + 1);
		# DOWN is y+. UP is y-.
		# Nice.

func do_fall(where : Vector2, chain : int):
	# warning-ignore-all:narrowing_conversion
	if get_block(where.x, where.y-1) != -1:
		# Not sure if returning silently when theres nothing to fall is a good idea.
		# Probably nbd.
		return;
	
	var slice = [];
	for row in range(where.y, len(_static_blocks[where.x])):
		if get_block(where.x, row) in SPECIAL_BLOCKS:
			break;
		slice.append(get_block(where.x, row));
		set_block(where.x, row, -1);
	clean_trailing_empty();
	
	if slice.empty():
		return;
	
	add_new_faller(where, slice, chain);

func add_new_faller(where : Vector2, slice : Array, chain : int):
	var faller : Faller = FALLER_SCRIPT.new(where, slice, _static_blocks[where.x], _chain_storage[where.x], chain);
	add_faller(faller);

func add_faller(faller : Faller):
	self.add_child(faller);
	_fallers.append(faller);
	
	faller.connect("done_falling", self, "on_Faller_done_falling");
	self.emit_signal("new_faller", faller);

func on_Faller_done_falling(faller : Faller) -> void:
	self._queue_check = true;
	_fallers.erase(faller);

func clean_trailing_empty() -> void:
	for col in range(get_width()):
		while not _static_blocks[col].empty() and _static_blocks[col].back() == -1:
			_static_blocks[col].pop_back();
			_chain_storage[col].pop_back();

# Getters
func is_settled() -> bool:
	return _fallers.empty() and _exploders.empty() and .is_settled();

# Debug
func column_to_string(col : int) -> String:
	# Terrible code but this is only for debugging.
	var out = "";
	for i in range(len(_static_blocks[col])):
		out += str(_static_blocks[col][i]) + "  ";

	var last = len(_static_blocks[col]);
	for faller in _fallers:
		if faller._x == col:
			out.erase(len(out)-1, 1);
			for i in range(last, faller._y):
				out += "   ";
			last = faller._y;
			
			out += "<"
			for content in faller._slice:
				out += str(content) + "  ";
			out.erase(len(out)-2, 2);
			out += "> ";
	return out;


func propagate_raise() -> void:
	pass # Replace with function body.
