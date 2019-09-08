extends Node2D

export (NodePath) var _model_path : NodePath;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var model : Blocks = self.get_node(_model_path);
	
	$TileMap.clear()
	for col in range(model.get_width()):
		for row in range(-3, 12):
			$TileMap.set_cell(col, row, model.get_block(col, row));
