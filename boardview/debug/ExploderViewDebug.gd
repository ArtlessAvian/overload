extends TileMap

var model : Exploder;
var first_y : int;

var explode_time : float;
var explode_count : int;

func _ready() -> void:
	if (get_parent() == get_viewport()):
		# Add Camera
		var cam = Camera2D.new()
		cam.current = true;
		add_child(cam);
		# Add Model
		print("Testing Exploder");
		var new_model = Exploder.new([Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)], [[1,2,3,4,5]]);
		add_child(new_model);
		set_model(new_model);

func set_model(new_model : Exploder):
	model = new_model;
	
	first_y = model._clears[0].y;
	$PanelContainer/Label.text = str(len(model._clears), " x", model._chain);
	$PanelContainer.rect_position = model._clears[-1] * 40;
	$PanelContainer.rect_position.y *= -1;
	$PanelContainer.rect_position.y -= $PanelContainer.rect_size.y;
	
	for i in range(len(model._clears)):
		var vec = model._clears[i];
		var color = model._colors[i];
		color = color if color >= 0 else 6;
		self.set_cell(vec.x, vec.y, color);

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	if (not is_instance_valid(model)) or model.is_queued_for_deletion():
		self.queue_free();
		return;
	
	self.position.y = round(-40 * (model._clears[0].y - first_y));
	self.explode_time += delta;
	if (explode_time > Exploder.EXPLODE_DELAY + Exploder.EXPLODE_PERIOD):
		explode_time -= Exploder.EXPLODE_PERIOD;
		if (explode_count < len(model._clears)):
			self.set_cellv(model._clears[explode_count], model._explode_into[explode_count]);
		explode_count += 1;
