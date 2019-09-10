extends "blocks/BlocksViewDebug.gd"

const FALLER_VIEW_SCENE = preload("res://board/dynamic_blocks/faller/FallerViewDebug.tscn");
const FALLER_VIEW_SCRIPT = preload("res://board/dynamic_blocks/faller/FallerViewDebug.gd");
# Hack. Avoids figuring out why the scene doesn't add the script?

var fallers = {};

func on_DynamicBlocksModel_new_faller(faller : Faller) -> void:
#	fallers.append(faller);
	fallers[faller] = FALLER_VIEW_SCENE.instance();
#	fallers[faller].set_script(FALLER_VIEW_SCRIPT.new(faller));
	fallers[faller]._init_custom(faller);
	self.add_child(fallers[faller]);
	faller.connect("done_falling", self, "on_Faller_done_falling");

func on_Faller_done_falling(faller):
	self.remove_child(fallers[faller]);
	fallers.erase(faller);