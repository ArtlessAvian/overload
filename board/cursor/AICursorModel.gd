extends Cursor
class_name AICursor

var _queue = [];

func _init(bounds : Vector2 = Vector2(6, 12)):
	._init("AI", bounds);

func _ready() -> void:
	set_process_input(false);

#var aaaaa = true;
#func _physics_process(delta: float) -> void:
#	if ($"..".get_height() < 10 and $"../DynamicBlocks".is_settled()):
#		request_raise();
#		aaaaa = not aaaaa;
#		_queue.clear();
#	else:
#		if not _queue.empty():
#			call(_queue.pop_front());
#		else:
#			for col in range(_bounds.x-1):
#				for row in range(_bounds.y-1, 0, -1):
#					if $"../DynamicBlocks".get_block(col, row) in Blocks.CANNOT_SWITCH:
#						continue;
#					if $"../DynamicBlocks".get_block(col+1, row) in Blocks.CANNOT_SWITCH:
#						continue;
#
#					var left = $"../DynamicBlocks".get_block(col, row)
#					var right = $"../DynamicBlocks".get_block(col+1, row)
#					if aaaaa and (left < right) or not aaaaa and (left > right):
#						queue_move_to(col, row);
#						print(col, row, _queue);
#						queue_swap();
#						return;
#
#func queue_move_to(col : int, row : int):
#	for i in range(_position.x, col):
#		_queue.push_back("right");
#	for i in range(col, _position.x):
#		_queue.push_back("left");
#	for i in range(_position.y, row):
#		_queue.push_back("up");
#	for i in range(row, _position.y):
#		_queue.push_back("down");
#
#func queue_swap():
#	_queue.push_back("request_swap");

func _physics_process(delta: float) -> void:
	if ($"..".get_height() < 10 and $"../DynamicBlocks".is_settled()):
		request_raise();
	else:
		if (Engine.get_frames_drawn() % 5 == 0):
			_position = Vector2(randi() % int(_bounds.x-1), randi() % int(_bounds.y));
			request_swap();