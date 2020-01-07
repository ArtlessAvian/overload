extends Node
class_name Faller
signal done_falling;

var _slice : Array;
var _x : int;
var _y : float;
var _static_col : Array;
var _chain_col : Array;
var _chain : int;

func _init(pos : Vector2, slice : Array, static_col : Array, chain_col : Array, chain : int = 1):
# warning-ignore-all:narrowing_conversion
# oh well.
	_x = pos.x;
	_y = pos.y;
	_slice = slice;
	_static_col = static_col;
	_chain_col = chain_col;
	_chain = chain;

func on_board_raise():
	_y += 1;

func _physics_process(delta: float) -> void:
	if self.is_queued_for_deletion():
		return;
		# GUT doesnt free stuff. >:(
	
	_y -= delta;
	if _y <= len(_static_col):
		# warning-ignore:narrowing_conversion
		var y_int : int = max(0, ceil(_y));
		if y_int <= 0 or _static_col[y_int - 1] != -1:
			# Backtrack when tunneling
			while self._is_tunneled(y_int):
				y_int += 1;
				print("tunneled!!");
			
			for offset in range(len(_slice)):
				if y_int + offset >= len(_static_col):
					_static_col.append(_slice[offset]);
					_chain_col.append(_chain);
				else:
					_static_col[y_int+offset] = _slice[offset];
					_chain_col[y_int+offset] = _chain;
			self.emit_signal("done_falling", self);
			self.queue_free()

func _is_tunneled(y : int) -> bool:
	for i in range(len(_slice)):
		if y+i + 1 <= 0 or (y+i < len(_static_col) and _static_col[y+i] != -1):
			return true;
	return false;