extends Node
class_name Hoverer
signal done_hovering

var _clears : Array;
var _chain : int;

var exist_time = 0;

func _init(clears : Array, chain : int = 1) -> void:
	self._clears = clears;
	self._chain = chain;

func _physics_process(delta: float) -> void:
	if self.is_queued_for_deletion():
		return;
		# GUT doesnt free stuff. >:(
	
	exist_time += delta;
	if exist_time >= 0.2:
		self.emit_signal("done_hovering", self, _clears, _chain);
		self.queue_free();

func on_board_raise():
	for i in range(len(_clears)):
		_clears[i].y += 1;
