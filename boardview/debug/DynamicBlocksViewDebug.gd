extends "BlocksViewDebug.gd"

const FALLER_VIEW_SCENE = preload("res://boardview/debug/FallerViewDebug.tscn");
const EXPLODER_VIEW_SCENE = preload("res://boardview/debug/ExploderViewDebug.tscn");

func _ready() -> void:
	if (get_parent() == get_viewport()):
		print("Testing DynamicBlocks");
		set_model(DynamicBlocks.new());

func set_model(new_model : DynamicBlocks):
	model = new_model;
	model.name = "DynamicBlocks";
	add_child(model);
	
	model.connect("new_faller", self, "new_faller");
	model.connect("new_exploder", self, "new_exploder");
	
func new_faller(faller : Faller) -> void:
#	fallers.append(faller);
	var view = FALLER_VIEW_SCENE.instance();
	view.set_owner(self);
#	fallers[faller].set_script(FALLER_VIEW_SCRIPT.new(faller));
	view._init_custom(faller);
	self.add_child(view);
#	faller.connect("done_falling", self, "on_Faller_done_falling");

#func on_Faller_done_falling(faller):
#	self.remove_child(fallers[faller]);
#	fallers.erase(faller);

func new_exploder(exploder : Exploder) -> void:
	var view = EXPLODER_VIEW_SCENE.instance();
	view.set_owner(self);
	view._init_custom(exploder);
	self.add_child(view);
