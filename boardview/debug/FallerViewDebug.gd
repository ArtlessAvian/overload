extends TileMap

var model : Faller;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		print("Testing Faller");
		_init_custom(Faller.new(Vector2(0, 10), [1, 2], [1, 2, 3, 4], [1, 1, 1, 1]));
		add_child(model);

func _init_custom(new_model) -> void:
	model = new_model;
	model.name = "Board";

	position.x = model._x * 40;
	for i in range(len(model._slice)):
		var el = model._slice[i];
		el = el if el >= 0 else 6;
		self.set_cell(0, i, el);

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	if (not is_instance_valid(model)) or model.is_queued_for_deletion():
		self.queue_free();
		return;
	
	position.y = round(model._y * -40);