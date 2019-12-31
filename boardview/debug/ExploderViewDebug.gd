extends TileMap

var _model : Exploder;
var _first_y : int;

func _init_custom(model : Exploder) -> void:
	_model = model;
	
	_first_y = _model._clears[0].y;
	$PanelContainer/Label.text = str(len(model._clears), " x", model._chain);
	$PanelContainer.rect_position = _model._clears[-1] * 40;
	$PanelContainer.rect_position.y *= -1;
	$PanelContainer.rect_position.y -= $PanelContainer.rect_size.y;
	
	for i in range(len(_model._clears)):
		var vec = _model._clears[i];
		var color = _model._colors[i];
		color = color if color >= 0 else 6;
		self.set_cell(vec.x, vec.y, color);

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	if (not is_instance_valid(_model)) or _model.is_queued_for_deletion():
		self.queue_free();
		return;
	
	self.position.y = round(-40 * (_model._clears[0].y - _first_y));