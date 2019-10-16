extends Node
class_name Board

var _dynamic_blocks : Blocks;
var _cursor : Cursor;

var _partial_raise : float = 0;

var _raise_requested = false;

func _ready() -> void:
	self._dynamic_blocks = DynamicBlocks.new(6);
	self.add_child(_dynamic_blocks);
	
	self._cursor = Cursor.new();
	self._dynamic_blocks.add_child(self._cursor);
	self._cursor.connect("raise_requested", self, "request_raise");
	self._cursor.connect("swap_requested", self._dynamic_blocks, "swap");
	
	for i in range(4):
		self._dynamic_blocks.raise();

func _physics_process(delta: float) -> void:
	self._partial_raise += delta * (0.2 if not self._raise_requested else 5.0);
	while self._partial_raise > 1:
		self._partial_raise -= 1;
		self._dynamic_blocks.raise();
		self._cursor.raise();
		self._raise_requested = false;
	pass

func request_raise() -> void:
	self._raise_requested = true;