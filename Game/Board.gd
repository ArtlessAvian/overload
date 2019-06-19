extends Node2D
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

### Inputs?
var garbage_inbox = 0;

### Game Constants
const EMPTY = -1;
const CLEARING = 5;
const GARBAGE = 6;
const force_raise_speed = 5;

### Options
export (String) var player = "kb";

export (int) var board_width = 6;
export (int) var board_height = 12;
export (int) var color_count = 5;

export (int) var grace_period = 1;

export (float) var explode_pause = 1.4;
export (float) var explode_interval = 0.1;

export (float) var rising_speed = 0.2;
export (float) var faller_speed = 10;

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
	$"AnimationPlayer".play("Lose");

# Game Logic
onready var grace = self.grace_period;

func _physics_process(delta):
	if $"Blocks".pause == 0 and $"Blocks/Exploders".get_child_count() == 0:
		if not $"Blocks".has_space():
			self.grace -= delta;
			if (self.grace <= 0):
				self.emit_signal("lost", self);
				self.lose();
		else:
			grace = self.grace_period;