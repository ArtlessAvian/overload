extends Sprite
# Always a direct child of Blocks.

const DRAW_OFFSET = Vector2(1, 0.5);
var cursor_pos = Vector2(2, 5) # Position of the left

func _ready():
	pass # Replace with function body.

func _process(_delta):
	var player = self.get_board().player;
	
	if (Input.is_action_just_pressed(player + "_up")):
		self.cursor_up();
	if (Input.is_action_just_pressed(player + "_down")):
		self.cursor_down();
	if (Input.is_action_just_pressed(player + "_left")):
		self.cursor_left();
	if (Input.is_action_just_pressed(player + "_right")):
		self.cursor_right();
	if (Input.is_action_just_pressed(player + "_swap")):
		self.cursor_swap();
	if (Input.is_action_just_pressed(player + "_swap2")):
		self.cursor_swap();
	if (Input.is_action_pressed(player + "_raise")):
		self.get_blocks().force_raise = true;
	
	self.position = self.cursor_pos;
	self.position += self.DRAW_OFFSET;
	self.position *= self.get_parent().cell_size;
	self.position.y *= -1;

func _physics_process(_delta):
	pass

func true_raise():
	self.cursor_up();

func cursor_up():
	if cursor_pos.y + 1 < self.get_board().board_height - int(self.get_blocks().has_space()):
		cursor_pos.y += 1;

func cursor_down():
	if cursor_pos.y - 1 >= 0:
		cursor_pos.y -= 1;

func cursor_left():
	if cursor_pos.x - 1 >= 0:
		cursor_pos.x -= 1;

func cursor_right():
	if cursor_pos.x + 1 < self.get_board().board_width - 1:
		cursor_pos.x += 1;

func cursor_swap():
	if (self.get_blocks().is_physics_processing()):
		self.get_blocks().queue_swap = cursor_pos;

# Parenting
func get_blocks():
	return self.get_parent();

func get_board():
	return self.get_blocks().get_board();