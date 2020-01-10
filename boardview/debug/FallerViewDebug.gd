extends TileMap

var model : Faller;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		# Add Camera
		var cam = Camera2D.new()
		cam.current = true;
		add_child(cam);
		# Add Model
		print("Testing Faller");
		var new_model = Faller.new(Vector2(0, 10), [1, 2], [1, 2, 3, 4], [1, 1, 1, 1]);
		add_child(new_model);
		set_model(new_model);

func set_model(new_model) -> void:
	model = new_model;
	
	position.x = model._x * 40;
	for i in range(len(model._slice)):
		var el = model._slice[i];
		el = el if el >= 0 else 6;
		self.set_cell(0, i, el);

func _process(delta) -> void:
	if (not is_instance_valid(model)) or model.is_queued_for_deletion():
		self.queue_free();
		return;
	
	position.y = round(model._y * -40);