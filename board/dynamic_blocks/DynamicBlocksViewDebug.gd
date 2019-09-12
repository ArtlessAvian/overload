extends "blocks/BlocksViewDebug.gd"

const FALLER_VIEW_SCENE = preload("res://board/dynamic_blocks/faller/FallerViewDebug.tscn");
const EXPLODER_VIEW_SCENE = preload("res://board/dynamic_blocks/exploder/ExploderViewDebug.tscn");

#var fallers = {};

func on_DynamicBlocksModel_new_faller(faller : Faller) -> void:
#	fallers.append(faller);
	var view = FALLER_VIEW_SCENE.instance();
#	fallers[faller].set_script(FALLER_VIEW_SCRIPT.new(faller));
	view._init_custom(faller);
	self.add_child(view);
#	faller.connect("done_falling", self, "on_Faller_done_falling");

#func on_Faller_done_falling(faller):
#	self.remove_child(fallers[faller]);
#	fallers.erase(faller);

func _on_DynamicBlocksModel_new_exploder(exploder : Exploder) -> void:
	var view = EXPLODER_VIEW_SCENE.instance();
	view._init_custom(exploder)
	self.add_child(view);