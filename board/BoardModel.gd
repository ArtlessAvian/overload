extends Node
class_name Board

var _raise_requested = false;
var _perform_raise = false;
var _faller_speed = 5;

var _partial_raise : float = 0;

func _init(ai : bool = false) -> void:
	var dynamic_blocks = DynamicBlocks.new(6);
	dynamic_blocks.name = "DynamicBlocks";
	dynamic_blocks.connect("new_faller", self, "new_faller"); # To hijack it
#	dynamic_blocks.connect("clear", self, "send_garbage"); 
	self.add_child(dynamic_blocks);
	
	var cursor = Cursor.new() if not ai else AICursor.new();
	cursor.name = "Cursor";
	cursor._bounds.x = 6;
	cursor.connect("raise_requested", self, "request_raise");
	cursor.connect("stop_raise_requested", self, "request_stop_raise");
	cursor.connect("swap_requested", $DynamicBlocks, "swap");
	self.add_child(cursor);
	
	for i in range(4):
		$DynamicBlocks.on_board_raise();

func _physics_process(delta: float) -> void:
	if $DynamicBlocks.is_settled() and get_height() < 12:
		self._partial_raise += delta * (0.2 if not self._perform_raise else 5.0);
		while self._partial_raise > 1:
			self._partial_raise -= 1;
			self.propagate_call("on_board_raise");
			self._perform_raise = self._raise_requested and get_height() < 12;
			if get_height() >= 12:
				self._partial_raise = 0;
#			$DynamicBlocks.receive_garbage(10);
	else:
		# Something is falling or the board is full
		self._perform_raise = false;
		
	for faller in $DynamicBlocks/Fallers.get_children():
		faller._physics_process(delta * _faller_speed);
	
	if (Input.is_action_just_pressed("ui_accept")):
		$DynamicBlocks.receive_garbage(10);

func request_raise() -> void:
	self._raise_requested = true;
	self._perform_raise = true;

func request_stop_raise() -> void:
#	print("received request")
	self._raise_requested = false;

func new_faller(faller : Faller) -> void:
	faller.set_physics_process(false);

func get_height() -> int:
	var out = 0;
	for col in $DynamicBlocks._static_blocks:
		out = max(out, len(col))
	return out;

#func send_garbage():
#	pass