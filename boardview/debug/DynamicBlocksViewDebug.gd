extends "BlocksViewDebug.gd"

const FALLER_VIEW_SCENE = preload("res://boardview/debug/FallerViewDebug.tscn");
const EXPLODER_VIEW_SCENE = preload("res://boardview/debug/ExploderViewDebug.tscn");

func _ready() -> void:
	if (get_parent() == get_viewport()):
		# Add Camera
		var cam = Camera2D.new()
		cam.current = true;
		add_child(cam);
		# Add Model
		print("Testing DynamicBlocks");
		var new_model = DynamicBlocks.new();
		add_child(new_model);
		set_model(new_model);

func set_model(new_model : Blocks):
	model = new_model;
	
	model.connect("new_faller", self, "new_faller");
	model.connect("new_exploder", self, "new_exploder");
	
func new_faller(faller : Faller) -> void:
	var view = FALLER_VIEW_SCENE.instance();
	view.set_model(faller);
	self.add_child(view);

func new_exploder(exploder : Exploder) -> void:
	var view = EXPLODER_VIEW_SCENE.instance();
	view.set_model(exploder);
	self.add_child(view);
