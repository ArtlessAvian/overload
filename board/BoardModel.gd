extends Node
class_name Board
signal lost

const BASE_RAISE_SPEED = 0.4;

export (int) var _faller_speed = 5;
export (int) var _grace_period = 2;

var _grace_timer = 0;
var _lost = false;

var _pause_timer = 0;

var _raise_requested = false;
var _perform_raise = false;
var _partial_raise : float = 0;

func _init(ai : bool = false) -> void:
	var dynamic_blocks = DynamicBlocks.new(6);
	dynamic_blocks.name = "DynamicBlocks";
	dynamic_blocks.connect("new_faller", self, "hijack_faller"); # To hijack it
	dynamic_blocks.connect("clear", self, "pause_for_clear"); 
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

# Physics Stuff

func _physics_process(delta: float) -> void:
	check_lose_condition(delta);
	do_raise(delta);
	fall_hijacked_fallers(delta)
	# TODO: REMOVE
#	if (Input.is_action_just_pressed("ui_accept")):
#		$DynamicBlocks.receive_garbage(10);

func check_lose_condition(delta : float) -> void:
	if get_height() >= 12 and $DynamicBlocks.is_settled():
		self._grace_timer -= delta;
		if self._grace_timer <= 0:
			self.lose()
	elif get_height() < 12:
		self._grace_timer = _grace_period;

func do_raise(delta : float) -> void:
	# The board only raises when blocks are settled
	if not $DynamicBlocks.is_settled():
		self._perform_raise = false;
		return;
	
	# The board only raises when the pause timer is over or interrupted
	if self._pause_timer > 0 and not self._perform_raise:
		self._pause_timer -= delta
		return
	else:
		self._pause_timer = 0;
		
	if get_height() < 12:
		self._partial_raise += delta * (BASE_RAISE_SPEED if not self._perform_raise else 5.0);
		while self._partial_raise > 1:
			self._partial_raise -= 1;
			self.propagate_call("on_board_raise");
			self._perform_raise = self._raise_requested and get_height() < 12;
			if get_height() >= 12:
				self._partial_raise = 0;
#			$DynamicBlocks.receive_garbage(10);
	
func fall_hijacked_fallers(delta : float) -> void:
	# Touhou Hijack LOL
	for faller in $DynamicBlocks/Fallers.get_children():
		faller._physics_process(delta * _faller_speed);

# End Physics Stuff

func lose() -> void:
	print("u died");
	self._lost = true;
	self.propagate_call("set_physics_process", [false]);
	self.propagate_call("set_input_process", [false]);
	pass

func get_height() -> int:
	var out = 0;
	for col in $DynamicBlocks._static_blocks:
		out = max(out, len(col))
	return out;

# Signal callbacks

func hijack_faller(faller : Faller) -> void:
	faller.set_physics_process(false);

func pause_for_clear(positions : Array, chain : int) -> void:
	self._pause_timer = max(self._pause_timer, chain * 0.5);

func request_raise() -> void:
	self._raise_requested = true;
	self._perform_raise = true;

func request_stop_raise() -> void:
#	print("received request")
	self._raise_requested = false;

#func send_garbage():
#	pass