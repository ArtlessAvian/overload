extends Node
class_name Board

var _dynamic_blocks : Blocks;
var _cursor : Cursor;

var _partial_raise : float = 0;

func _ready() -> void:
	self._dynamic_blocks = DynamicBlocks.new(6);
	self.add_child(_dynamic_blocks);
	
	self._cursor = Cursor.new();
	self._dynamic_blocks.add_child(self._cursor);
	self._cursor.connect("raise_requested", self._dynamic_blocks, "raise");
	self._cursor.connect("swap_requested", self._dynamic_blocks, "swap");
	
#	for i in range(3000):
#		self._dynamic_blocks.raise();

func _physics_process(delta: float) -> void:
	self._partial_raise += delta * 0.2;
	while self._partial_raise > 1:
		self._partial_raise -= 1;
		self._dynamic_blocks.raise();
		self._cursor.raise();
	pass