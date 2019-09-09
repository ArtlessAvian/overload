extends Node2D
class_name Exploder
signal done_exploding

const EXPLODE_DELAY = 0.5;
const EXPLODE_PERIOD = 0.1;

var _clears : Array;
var _colors : Array;

var exist_time = 0;

func _init(clears : Array, blocks : Blocks) -> void:
	_clears = clears;
	_colors = [];
	for vec in _clears:
		_colors.append(blocks.get_block(vec.x, vec.y));
		blocks.set_block(vec.x, vec.y, 6);
		# oh my god vec.y, look

func _physics_process(delta: float) -> void:
	exist_time += delta;
	if exist_time >= EXPLODE_DELAY + EXPLODE_PERIOD * len(_clears):
		self.emit_signal("done_exploding", _clears, _colors);
		self.queue_free();

func on_raise():
	for i in range(len(_clears)):
		_clears[i].y += 1;