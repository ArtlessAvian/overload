extends Node2D

export (NodePath) var model_path : NodePath;

func _process(delta : float) -> void:
	$"DynamicBlocksViewDebug".position.y = round(get_node(model_path)._partial_raise * -40);
