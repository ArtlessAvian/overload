extends TileMap

var _model : Faller;

func _init_custom(model) -> void:
	_model = model;
	position.x = _model._x * 40;
	for i in range(len(_model._slice)):
		self.set_cell(0, i, _model._slice[i]);

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	if (not is_instance_valid(_model)) or _model.is_queued_for_deletion():
		self.queue_free();
		return;
	
	position.y = round(_model._y * -40);