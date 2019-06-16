extends Sprite

const DRAW_OFFSET = Vector2(1, 0.5);
var cursor_pos = Vector2(2, 5) # Position of the left

func _ready():
	pass # Replace with function body.

func _process(delta):
	if (Input.is_action_just_pressed($"../..".player + "_up")):
		self.cursor_up();
	if (Input.is_action_just_pressed($"../..".player + "_down")):
		self.cursor_down();
	if (Input.is_action_just_pressed($"../..".player + "_left")):
		self.cursor_left();
	if (Input.is_action_just_pressed($"../..".player + "_right")):
		self.cursor_right();
	if (Input.is_action_just_pressed($"../..".player + "_swap")):
		self.cursor_swap();
	if (Input.is_action_just_pressed($"../..".player + "_swap2")):
		self.cursor_swap();
	if (Input.is_action_pressed($"../..".player + "_raise")):
		$"..".raise = true;
	pass

func _physics_process(delta):
	pass

func true_raise():
	self.cursor_up();

func cursor_up():
	if cursor_pos.y + 1 < $"../..".board_height - int($"..".has_space()):
		cursor_pos.y += 1;

func cursor_down():
	if cursor_pos.y - 1 >= 0:
		cursor_pos.y -= 1;

func cursor_left():
	if cursor_pos.x - 1 >= 0:
		cursor_pos.x -= 1;

func cursor_right():
	if cursor_pos.x + 1 < $"../..".board_width - 1:
		cursor_pos.x += 1;

func cursor_swap():
	$"..".swap(cursor_pos.x, cursor_pos.y);