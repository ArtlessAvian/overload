extends Node2D

var model : Blocks;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (get_parent() == get_viewport()):
		# Add Camera
		var cam = Camera2D.new()
		cam.current = true;
		add_child(cam);
		# Add Model
		print("Testing Blocks");
		var new_model = Blocks.new();
		add_child(new_model);
		set_model(new_model);

func set_model(new_model : Blocks):
	model = new_model;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$TileMap.clear();
	for col in range(model.get_width()):
		for row in range(-1, 12):
			var tile = model.get_block(col, row);
			tile = tile if not tile in [-2, -3] else -1;
			$TileMap.set_cell(col, row, tile);

	$TileMap2.clear();
	for col in range(model.get_width()):
		for row in range(len(model._chain_storage[col])):
			$TileMap2.set_cell(col, row, model._chain_storage[col][row]);