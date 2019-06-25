extends Resource
class_name BoardOptions

#warning-ignore-all:unused_signal
#warning-ignore-all:unused_class_variable

### Game Constants
const EMPTY = 7;
const CLEARING = 5;
const GARBAGE = 6;
const force_raise_speed = 5;

### Options
export (String) var player = "kb";

export (int) var board_width = 6;
export (int) var board_height = 12;
export (int) var color_count = 5;
export (Vector2) var cell_size = Vector2(40, 40);

export (int) var grace_period = 1;

export (float) var explode_pause = 1.0;
export (float) var explode_interval = 0.1;

export (float) var rising_speed = 0.2;
export (float) var faller_speed = 10;