extends Node2D
class_name Board
# Keeps abstraction between the gamemodes and the blocks
# Ideally gamemodes don't need to know anything beyond the signals and options
# and the blocks dont need to know anything beyond the inputs. 

# One to one correspondence with Blocks, as its parent.

#warning-ignore-all:unused_signal
#warning-ignore-all:unused_class_variable

### Signals
signal round_ready;
signal lost;
signal clear;

const DEFAULT_OPTIONS : BoardOptions = preload("res://Options/Default.tres");

### Inputs?
var garbage_inbox = 0;
export (Resource) var board_options : Resource;

func _enter_tree():
	if (board_options == null):
		self.board_options = DEFAULT_OPTIONS;
	self.propagate_call("set_board_options", [board_options]);

func pre_round_start():
	$"Blocks".set_physics_process(false);
	$"AnimationPlayer".play("Start");

func round_start():
	$"Blocks".set_physics_process(true);

func pause():
	$"Blocks".set_physics_process(false);

func unpause():
	$"Blocks".set_physics_process(true);

func lose():
	$"Blocks".set_physics_process(false);
	self.set_physics_process(false);
	$"AnimationPlayer".play("Lose");

# Game Logic
onready var grace = self.board_options.grace_period;

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_home"):
		self.garbage_inbox += 3;
	
	if not $"Blocks".any_exploder_active(): # Do not merge with below line.
		if $"Blocks".pause <= 0:
			if not $"Blocks".has_space():
				self.grace -= delta;
				if (self.grace <= 0):
					self.emit_signal("lost", self);
					self.lose();
			else:
				grace = self.board_options.grace_period;
			if self.garbage_inbox > 0:
				$Blocks.receive_garbage(self.garbage_inbox);
				self.garbage_inbox = 0;
			

func _on_Blocks_clear(chain, combo, garbage):
	self.emit_signal("clear", self, chain, combo, garbage);