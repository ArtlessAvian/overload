extends Node2D
# Keeps abstraction between the gamemodes and the blocks
# Ideally gamemodes don't need to know anything beyond the signals and options
# and the blocks dont need to know anything beyond the inputs. 

# One to one correspondence with Blocks, as its parent.

#warning-ignore-all:unused_signal
#warning-ignore-all:unused_class_variable

### Signals
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
