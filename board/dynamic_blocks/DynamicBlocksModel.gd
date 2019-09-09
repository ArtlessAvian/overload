extends "blocks/BlocksModel.gd"
class_name DynamicBlocks
signal new_exploder; # Exploder Model
signal new_faller; # Faller Model

const EXPLODER_SCENE = preload("res://board/dynamic_blocks/exploder/ExploderModel.gd");

func do_clears(clears : Array):
	var exploder : Exploder = EXPLODER_SCENE.new(clears, self);
	self.add_child(exploder);
	exploder.connect("done_exploding", self, "on_Exploder_done_exploding")
	self.emit_signal("new_exploder", exploder)

func on_Exploder_done_exploding(clears, colors):
	for clear in clears:
		set_block(clear.x, clear.y, -1);

func clean_trailing_empty():
	for col in _static_blocks:
		while col.back() == -1:
			col.pop_back();