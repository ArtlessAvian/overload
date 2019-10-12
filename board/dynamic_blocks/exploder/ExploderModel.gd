extends Node2D
class_name Exploder
signal done_exploding

const EXPLODE_DELAY = 0.5;
const EXPLODE_PERIOD = 0.1;

var _clears : Array;
var _colors : Array;
var _static_blocks : Array;

var _combo : int;

var exist_time = 0;

func _init(clears : Array, static_blocks : Array) -> void:
	_clears = clears;
	_static_blocks = static_blocks;
	
	_colors = [];
	for vec in _clears:
		_colors.append(_static_blocks[vec.x][vec.y]);
		_static_blocks[vec.x][vec.y] = 6;

func _physics_process(delta: float) -> void:
	exist_time += delta;
	if exist_time >= EXPLODE_DELAY + EXPLODE_PERIOD * len(_clears):
		for vec in _clears:
			_static_blocks[vec.x][vec.y] = -1;
		
		self.emit_signal("done_exploding", self, _clears, _colors, _combo);
		self.queue_free();

func on_raise():
	for i in range(len(_clears)):
		_clears[i].y += 1;