extends Node2D

var model : Node;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (get_parent() == get_viewport()):
		print("Testing Blocks");
		model = Blocks.new();
		model.name = "Blocks";
		add_child(model);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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