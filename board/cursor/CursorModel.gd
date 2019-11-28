extends Node
class_name Cursor
signal swap_requested; # Vector2.
signal raise_requested; # Vector2.
signal stop_raise_requested;

var _player : String;
var _blocks : Blocks;
var _bounds : Vector2;
var _position : Vector2;

func _init(player : String = "kb", bounds : Vector2 = Vector2(6, 12)):
	_player = player;
	_bounds = bounds;
	_position = Vector2(floor(bounds.x/2 - 1), floor((bounds.y-1)/2));

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_player + "_up"):
		up();
	elif event.is_action_pressed(_player + "_down"):
		down();
	elif event.is_action_pressed(_player + "_left"):
		left();
	elif event.is_action_pressed(_player + "_right"):
		right();
	
	elif event.is_action_pressed(_player + "_swap"):
		request_swap();
	elif event.is_action_pressed(_player + "_raise"):
		request_raise();
	elif event.is_action_released(_player + "_raise"):
		request_stop_raise();

func up():
	if _position.y + 1 < _bounds.y:
		_position.y += 1;

func down():
	if _position.y - 1 >= 0:
		_position.y -= 1;

func left():
	if _position.x - 1 >= 0:
		_position.x -= 1;

func right():
	if _position.x + 1 + 1 < _bounds.x:
		_position.x += 1;

func request_swap():
	self.emit_signal("swap_requested", _position);

func request_raise():
	self.emit_signal("raise_requested");

func request_stop_raise():
	self.emit_signal("stop_raise_requested");

func raise():
	self.up();