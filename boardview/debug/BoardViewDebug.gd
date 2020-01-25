extends Node2D
#class_name BoardViewDebug

var model : Board;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		# Add Camera
		var cam = Camera2D.new()
		cam.current = true;
		add_child(cam);
		# Add Model
		print("Testing Board");
		var new_model = Board.new();
		add_child(new_model);
		set_model(new_model);

func set_model(new_model : Board):
	model = new_model;
	$DynamicBlocksViewDebug.set_model(model.get_node("DynamicBlocks"));
	$DynamicBlocksViewDebug/CursorViewDebug.model = model.get_node("Cursor");

func _process(delta : float) -> void:
	# this is some garbo
	# but itll be replaced
#	$"DynamicBlocksViewDebug".position.x = 20 * (6 - len(get_node(model_path)._dynamic_blocks._static_blocks));
	
	$"DynamicBlocksViewDebug".position.y = round(model._partial_raise * -40);
	$Label.text = ""
	$Label.text += "Grace: " + str(model._grace_timer);
	$Label.text += "\n";
	$Label.text += "Pause: " + str(model._pause_timer);
	
	$"U DIED".visible = model._lost;
