extends Node
class_name Exploder
signal done_exploding

const EXPLODE_DELAY = 1;
const EXPLODE_PERIOD = 0.16;

var _clears : Array;
var _colors : Array;
var _explode_into : Array;
var _static_blocks : Array;

var _chain : int;

var exist_time = 0;

func _init(clears : Array, static_blocks : Array, chain : int = 1) -> void:
	_clears = clears;
	_static_blocks = static_blocks;
	_chain = chain;
	
	_colors = [];
	_explode_into = [];
	for vec in _clears:
		_colors.append(_static_blocks[vec.x][vec.y]);
		var garbage = _static_blocks[vec.x][vec.y] < 0;
		_explode_into.append(-1 if not garbage else randi() % 5);
		_static_blocks[vec.x][vec.y] = -2;

func _physics_process(delta: float) -> void:
	if self.is_queued_for_deletion():
		return;
		# GUT doesnt free stuff. >:(
	
	exist_time += delta;
	if exist_time >= EXPLODE_DELAY + EXPLODE_PERIOD * len(_clears):
		for i in len(_clears):
			var vec = _clears[i];
			_static_blocks[vec.x][vec.y] = _explode_into[i];
		
		self.emit_signal("done_exploding", self, _clears, _colors, _chain);
		self.queue_free();

func on_board_raise():
	for i in range(len(_clears)):
		_clears[i].y += 1;
