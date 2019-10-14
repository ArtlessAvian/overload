extends Node2D

export (NodePath) var model_path : NodePath;

func _process(delta : float) -> void:
	self.position.y = get_node(model_path)._partial_raise * -40;
	self.position.y = round(self.position.y)