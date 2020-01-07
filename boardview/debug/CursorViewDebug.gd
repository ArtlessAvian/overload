extends Sprite

var model : Cursor;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		print("Testing Cursor");
		model = Cursor.new();
		model.name = "Cursor";
		add_child(model);

func _process(delta: float) -> void:
	self.position = model._position * 40;
	self.position.y *= -1;
