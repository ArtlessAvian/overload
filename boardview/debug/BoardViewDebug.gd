extends Node2D
class_name BoardViewDebug

var model : Board;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		print("Testing Board");
		model = Board.new();
		model.name = "Board";
		add_child(model);
		
		$DynamicBlocksViewDebug.set_model(model.get_node("DynamicBlocks"));
		$DynamicBlocksViewDebug/CursorViewDebug.model = model.get_node("Cursor");

func _process(delta : float) -> void:
	# this is some garbo
	# but itll be replaced
#	$"DynamicBlocksViewDebug".position.x = 20 * (6 - len(get_node(model_path)._dynamic_blocks._static_blocks));
	
	$"DynamicBlocksViewDebug".position.y = round(model._partial_raise * -40);
