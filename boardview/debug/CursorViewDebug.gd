extends Sprite

var model : Cursor;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		# Add Camera
		var cam = Camera2D.new()
		cam.current = true;
		add_child(cam);
		# Add Model
		print("Testing Cursor");
		var new_model = Cursor.new();
		add_child(new_model);
		set_model(new_model);

func set_model(new_model : Cursor):
	model = new_model;

func _process(delta: float) -> void:
	self.position = model._position * 40;
	self.position.y *= -1;
