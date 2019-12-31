extends Node2D
class_name Exploder
signal done_exploding

const EXPLODE_DELAY = 0.5;
const EXPLODE_PERIOD = 0.1;

var _clears : Array;
var _colors : Array;
var _static_blocks : Array;

var _chain : int;

var exist_time = 0;

func _init(clears : Array, static_blocks : Array, chain : int = 1) -> void:
	_clears = clears;
	_static_blocks = static_blocks;
	_chain = chain;
	
	_colors = [];
	for vec in _clears:
		_colors.append(_static_blocks[vec.x][vec.y]);
		_static_blocks[vec.x][vec.y] = -2;

func _physics_process(delta: float) -> void:
	if self.is_queued_for_deletion():
		return;
		# GUT doesnt free stuff. >:(
	
	exist_time += delta;
	if exist_time >= EXPLODE_DELAY + EXPLODE_PERIOD * len(_clears):
		for i in len(_clears):
			var vec = _clears[i];
			var garbage = _colors[i] < 0;
			_static_blocks[vec.x][vec.y] = -1 if not garbage else randi() % 5; # TODO: figure out how to get num colors here
		
		self.emit_signal("done_exploding", self, _clears, _colors, _chain);
		self.queue_free();

func on_board_raise():
	for i in range(len(_clears)):
		_clears[i].y += 1;
