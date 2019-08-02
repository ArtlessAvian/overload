extends Sprite
class_name Cursor

signal swap;
signal raise;

# Always a direct child of Blocks.
var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

##### TODO: TEMPORARY PUT HERE FOR NOWWWWW.
export (String) var player = "kb";

export (float) var cursor_das = 0.5;
export (float) var cursor_arr = 1.0/60; # Assumes ARR is less than DAS
#####

const DRAW_OFFSET = Vector2(1, 0.5);
var cursor_pos = Vector2(2, 5) # Position of the left

# TODO: Make less crude
var vertical_held = 0;
var horizontal_held = 0;

func _ready():
	pass # Replace with function body.

func _process(delta):
	if (Input.is_action_just_pressed(player + "_up")):
		self.cursor_up();
		vertical_held = 0;
	if (Input.is_action_just_pressed(player + "_down")):
		self.cursor_down();
		vertical_held = 0;
	if (Input.is_action_just_pressed(player + "_left")):
		self.cursor_left();
		horizontal_held = 0;
	if (Input.is_action_just_pressed(player + "_right")):
		self.cursor_right();
		horizontal_held = 0;

	var horizontal = int(Input.is_action_pressed(player + "_right")) - int(Input.is_action_pressed(player + "_left"));
	if horizontal != 0:
		horizontal_held += delta;
		while horizontal_held > cursor_das:
			if horizontal == 1:
				self.cursor_right();
			else:
				self.cursor_left();
			horizontal_held -= cursor_arr;
	
	var vertical = int(Input.is_action_pressed(player + "_down")) - int(Input.is_action_pressed(player + "_up"));
	if vertical != 0:
		vertical_held += delta;
		while vertical_held > cursor_das:
			if vertical == 1:
				self.cursor_down();
			else:
				self.cursor_up();
			vertical_held -= cursor_arr;
	
	if (Input.is_action_just_pressed(player + "_swap")):
		self.cursor_swap();
	elif (Input.is_action_just_pressed(player + "_swap2")):
		self.cursor_swap();
	if (Input.is_action_pressed(player + "_raise")):
		self.request_raise();
	
	self.position = self.cursor_pos;
	self.position += self.DRAW_OFFSET;
	self.position *= self.get_parent().cell_size;
	self.position.y *= -1;

func _physics_process(_delta):
	pass

func true_raise():
	self.cursor_up();

func cursor_up():
	if cursor_pos.y + 1 < self.board_options.board_height:
		cursor_pos.y += 1;

func cursor_down():
	if cursor_pos.y - 1 >= 0:
		cursor_pos.y -= 1;

func cursor_left():
	if cursor_pos.x - 1 >= 0:
		cursor_pos.x -= 1;

func cursor_right():
	if cursor_pos.x + 1 + 1 < self.board_options.board_width:
		cursor_pos.x += 1;

func cursor_swap():
	self.emit_signal("swap", cursor_pos);

func request_raise():
	self.emit_signal("raise");