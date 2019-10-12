extends Sprite

export (NodePath) var model_path : NodePath;

func _process(delta: float) -> void:
	self.position = get_node(model_path)._position * 40;
	self.position.y *= -1;
