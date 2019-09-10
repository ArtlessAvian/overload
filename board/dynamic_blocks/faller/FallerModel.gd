extends Node2D
class_name Faller
signal done_falling;

var _slice : Array;
var _x : int;
var _y : float;
var _static_col : Array;
var _chain_col : Array;
var _chain : int;

func _init(slice : Array, x : int, y : int, static_col : Array, chain_col : Array, chain : int = 1):
	_slice = slice;
	_x = x;
	_y = y;
	_static_col = static_col;
	_chain_col = chain_col;
	_chain = chain;
	
func on_raise():
	_y += 1;
	pass

func _physics_process(delta: float) -> void:
	_y -= delta;
	if _y <= len(_static_col):
		# warning-ignore:narrowing_conversion
		var y_int : int = max(0, ceil(_y));
		if y_int == 0 or _static_col[y_int - 1] != -1:
			for offset in range(len(_slice)):
				if y_int + offset >= len(_static_col):
					_static_col.append(_slice[offset]);
					_chain_col.append(_chain);
				else:
					_static_col[y_int+offset] = _slice[offset];
					_chain_col[y_int+offset] = _chain;
			self.emit_signal("done_falling", self);
			self.queue_free()