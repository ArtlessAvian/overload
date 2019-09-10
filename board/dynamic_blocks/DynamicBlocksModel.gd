extends "blocks/BlocksModel.gd"
class_name DynamicBlocks
signal new_exploder; # Exploder Model
signal new_faller; # Faller Model

const EXPLODER_SCRIPT = preload("res://board/dynamic_blocks/exploder/ExploderModel.gd");
const FALLER_SCRIPT = preload("res://board/dynamic_blocks/faller/FallerModel.gd");

func push_up():
	.push_up();
	propagate_call("on_raise");

func do_clears(clears : Array):
	var exploder : Exploder = EXPLODER_SCRIPT.new(clears, self);
	self.add_child(exploder);
	exploder.connect("done_exploding", self, "on_Exploder_done_exploding");
	self.emit_signal("new_exploder", exploder);

func on_Exploder_done_exploding(exploder, clears, colors):
	for clear in clears:
		set_block(clear.x, clear.y, -1);
	
	# Reverse order for descending y.
	for i in range(len(clears)-1, -1, -1):
		do_fall(clears[i] + Vector2.DOWN);
		# DOWN is y+. UP is y-.
		# Nice.

func do_fall(where : Vector2, chain : int = 1):
	print(where)
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
	
	var faller : Faller = FALLER_SCRIPT.new(slice, where.x, where.y, _static_blocks[where.x], _chain_storage[where.x], chain);
	self.add_child(faller);
	faller.connect("done_falling", self, "on_Faller_done_falling");
	self.emit_signal("new_faller", faller);

func on_Faller_done_falling(faller):
	self._queue_check = true;

func clean_trailing_empty():
	for col in _static_blocks:
		while col.back() == -1:
			col.pop_back();
