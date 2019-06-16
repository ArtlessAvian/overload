extends Node2D
signal lost;
signal chain;
signal combo;

const EMPTY = -1;
const CLEARING = 5;
const GARBAGE = 6;

export (String) var player = "kb";

export (int) var board_width = 6;
export (int) var board_height = 12;
export (int) var color_count = 5;

export (int) var grace_period = 1;

export (float) var explode_pause = 0.7;
export (float) var explode_interval = 0.1;

export (float) var rising_speed = 0.2;
export (float) var faller_speed = 10;