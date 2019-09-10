extends "res://addons/GUT/test.gd"

const CURSOR_SCRIPT = "res://board/cursor/CursorModel.gd";
const CURSOR_PRELOAD = preload(CURSOR_SCRIPT);

func test_initable():
	assert_not_null(CURSOR_PRELOAD.new());

func test_cursor_starts_middle():
	var c : Cursor;
	c = CURSOR_PRELOAD.new("doesn't matter", Vector2(2, 2));
	assert_eq(c._position, Vector2(0, 0));
	c = CURSOR_PRELOAD.new("doesn't matter", Vector2(3, 3));
	assert_eq(c._position, Vector2(0, 1));
	c = CURSOR_PRELOAD.new("doesn't matter", Vector2(4, 4));
	assert_eq(c._position, Vector2(1, 1));

func test_cursor_doesnt_oob_up():
	var c : Cursor = CURSOR_PRELOAD.new("doesn't matter", Vector2(5, 5));
	assert_eq(c._position, Vector2(1, 2));
	c.up();
	c.up();
	assert_eq(c._position, Vector2(1, 4));
	c.up();
	assert_eq(c._position, Vector2(1, 4));

func test_cursor_doesnt_oob_down():
	var c : Cursor = CURSOR_PRELOAD.new("doesn't matter", Vector2(5, 5));
	assert_eq(c._position, Vector2(1, 2));
	c.down();
	c.down();
	assert_eq(c._position, Vector2(1, 0));
	c.down();
	assert_eq(c._position, Vector2(1, 0));

func test_cursor_doesnt_oob_left():
	var c : Cursor = CURSOR_PRELOAD.new("doesn't matter", Vector2(5, 5));
	assert_eq(c._position, Vector2(1, 2));
	c.left();
	assert_eq(c._position, Vector2(0, 2));
	c.left();
	assert_eq(c._position, Vector2(0, 2));

func test_cursor_doesnt_oob_right():
	var c : Cursor = CURSOR_PRELOAD.new("doesn't matter", Vector2(5, 5));
	assert_eq(c._position, Vector2(1, 2));
	c.right();
	c.right();
	assert_eq(c._position, Vector2(3, 2));
	c.right();
	assert_eq(c._position, Vector2(3, 2));

func test_swap_arg_correct():
	var c : Cursor = CURSOR_PRELOAD.new("doesn't matter", Vector2(5, 5));
	assert_eq(c._position, Vector2(1, 2));
	
	watch_signals(c);
	c.swap();
	assert_signal_emitted_with_parameters(c, "swap_requested", [Vector2(1, 2)])