extends TileMap

func _process(_delta: float) -> void:
	self.clear();
	for i in $"..".move_queue:
		self.set_cell(i.x, -i.y-1, 0)
