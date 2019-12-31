extends Node2D

export (NodePath) var model_path : NodePath;

func _process(delta : float) -> void:
	# this is some garbo
	# but itll be replaced
#	$"DynamicBlocksViewDebug".position.x = 20 * (6 - len(get_node(model_path)._dynamic_blocks._static_blocks));
	
	$"DynamicBlocksViewDebug".position.y = round(get_node(model_path)._partial_raise * -40);
