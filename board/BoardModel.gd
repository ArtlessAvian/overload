extends Node
class_name Board

var _dynamic_blocks : Blocks;
var _cursor : Cursor;

var _raise_requested = false;
var _faller_speed = 5;

var _partial_raise : float = 0;

func _ready() -> void:
	self._dynamic_blocks = DynamicBlocks.new(6);
	self.add_child(_dynamic_blocks);
	self._dynamic_blocks.connect("new_faller", self, "new_faller");
	
	self._cursor = Cursor.new();
	self.add_child(self._cursor);
	self._cursor.connect("raise_requested", self, "request_raise");
	self._cursor.connect("swap_requested", self._dynamic_blocks, "swap");
	
	for i in range(4):
		self._dynamic_blocks.raise();

func _physics_process(delta: float) -> void:
	self._partial_raise += delta * (0.2 if not self._raise_requested else 5.0);
	while self._partial_raise > 1:
		self._partial_raise -= 1;
		self.propagate_call("raise");
		self._raise_requested = false;
		
	for faller in self._dynamic_blocks._fallers:
		faller._physics_process(delta * _faller_speed);

func request_raise() -> void:
	self._raise_requested = true;

func new_faller(faller : Faller) -> void:
	faller.set_physics_process(false);