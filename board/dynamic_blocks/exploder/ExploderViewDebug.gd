extends TileMap

var _model : Exploder;
var _first_y : int;

func _init_custom(model) -> void:
	_model = model;
	
	_first_y = _model._clears[0].y;
	
	for i in range(len(_model._clears)):
		var vec = _model._clears[i];
		self.set_cell(vec.x, vec.y, _model._colors[i]);

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	if (not is_instance_valid(_model)) or _model.is_queued_for_deletion():
		self.queue_free();
		return;
	
	self.position.y = -40 * (_model._clears[0].y - _first_y);