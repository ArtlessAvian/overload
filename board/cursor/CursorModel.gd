extends Node2D
class_name Cursor
signal swap # Vector2.
signal raise # Vector2.

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
		up()
	if event.is_action_pressed(_player + "_down"):
		down()
	if event.is_action_pressed(_player + "_left"):
		left()
	if event.is_action_pressed(_player + "_right"):
		right()
	
	if event.is_action_pressed(_player + "_swap"):
		swap()
	if event.is_action_pressed(_player + "_raise"):
		raise()

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

func swap():
	self.emit_signal("swap", _position);

func raise():
	self.emit_signal("raise");