extends Node2D

export (NodePath) var model_path : NodePath;

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	var model : Blocks = self.get_node(model_path);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var model : Blocks = self.get_node(model_path);
	
	$TileMap.clear();
	for col in range(model.get_width()):
		for row in range(-3, 12):
			var tile = model.get_block(col, row);
			tile = tile if not tile in [-2, -3] else 6;
			$TileMap.set_cell(col, row, tile);

	$TileMap2.clear();
	for col in range(model.get_width()):
		for row in range(len(model._chain_storage[col])):
			$TileMap2.set_cell(col, row, model._chain_storage[col][row]);