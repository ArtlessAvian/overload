extends "blocks/BlocksModel.gd"
class_name DynamicBlocks
signal new_exploder; # Exploder Model
signal new_faller; # Faller Model

const EXPLODER_SCRIPT = preload("res://board/dynamic_blocks/exploder/ExploderModel.gd");
const FALLER_SCRIPT = preload("res://board/dynamic_blocks/faller/FallerModel.gd");

var _exploders : Array = [];
var _fallers : Array = [];

func raise():
	.raise();
	propagate_call("on_raise");

func swap(where : Vector2):
	for faller in _fallers:
		if faller._x == where.x or faller._x == where.x+1:
			if floor(faller._y) <= where.y and where.y < floor(faller._y + len(faller._slice)):
				return;
	
	.swap(where);

func do_clears(clears : Array):
	var exploder : Exploder = EXPLODER_SCRIPT.new(clears, _static_blocks);
	self.add_child(exploder);
	exploder.connect("done_exploding", self, "on_Exploder_done_exploding");
	self.emit_signal("new_exploder", exploder);

func on_Exploder_done_exploding(exploder, clears, colors):
	clean_trailing_empty();
	# Reverse order for descending y.
	for i in range(len(clears)-1, -1, -1):
		do_fall(clears[i] + Vector2.DOWN);
		# DOWN is y+. UP is y-.
		# Nice.

func do_fall(where : Vector2, chain : int = 1):
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
	
	var faller : Faller = FALLER_SCRIPT.new(where, 5, slice, _static_blocks[where.x], _chain_storage[where.x], chain);
	self.add_child(faller);
	_fallers.append(faller);
	
	faller.connect("done_falling", self, "on_Faller_done_falling");
	self.emit_signal("new_faller", faller);

func on_Faller_done_falling(faller):
	self._queue_check = true;
	_fallers.erase(faller);

func clean_trailing_empty():
	for col in range(get_width()):
		while _static_blocks[col].back() == -1:
			_static_blocks[col].pop_back();
			_chain_storage[col].pop_back();