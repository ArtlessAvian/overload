extends "res://addons/GUT/test.gd"

var BlocksScript = load("res://board/blocks/BlocksModel.gd");

func test_initable():
	assert_not_null(BlocksScript.new());

func test_get_set_width():
	var b : Blocks = BlocksScript.new();
	assert_accessors(b, "width", 0, 6);

func test_detect_in_a_row():
	var b : Blocks = BlocksScript.new();
	assert_eq(b.detect_in_a_row([]), []);
	assert_eq(b.detect_in_a_row([0]), []);
	assert_eq(b.detect_in_a_row([0, 0]), []);
	assert_eq(b.detect_in_a_row([0, 0, 0]), [0, 1, 2]);
	assert_eq(b.detect_in_a_row([0, 0, 0, 0]), [0, 1, 2, 3]);
	assert_eq(b.detect_in_a_row([0, 0, 0, 0, 0]), [0, 1, 2, 3, 4]);
	assert_eq(b.detect_in_a_row([1, 0, 0, 0, 1]), [1, 2, 3]);
	assert_eq(b.detect_in_a_row([1, 1, 1, 0, 0, 0]), [0, 1, 2, 3, 4, 5]);

func test_detect_in_jagged():
	var b : Blocks = BlocksScript.new();

	# Not enough blocks
	assert_true(b.detect_in_jagged([]).empty());
	assert_true(b.detect_in_jagged([[]]).empty());
	assert_true(b.detect_in_jagged([[], [], [], [], [], []]).empty());
	assert_true(b.detect_in_jagged([[0]]).empty());
	assert_true(b.detect_in_jagged([[0, 0]]).empty());
	assert_true(b.detect_in_jagged([[0], [0]]).empty());

	# Direct Success
	assert_false(b.detect_in_jagged([[0, 0, 0]]).empty());
	assert_false(b.detect_in_jagged([[0], [0], [0]]).empty());

	# Offset
	assert_false(b.detect_in_jagged([[1, 0, 0, 0]]).empty());
	assert_false(b.detect_in_jagged([[1], [0, 0, 0]]).empty());
	assert_false(b.detect_in_jagged([[1], [0], [0], [0]]).empty());
	assert_false(b.detect_in_jagged([[1, 0], [2, 0], [3,0]]).empty());

	var big_checker = [];
	for i in range(20):
		big_checker.append([]);
		for j in range(20):
			big_checker[i].append((i + j) % 2);
	assert_true(b.detect_in_jagged(big_checker).empty());

	var very_jagged = [];
	for i in range(20):
		very_jagged.append([]);
		for j in range((i % 3) * 10):
			very_jagged[i].append((i + j) % 6);
	assert_true(b.detect_in_jagged(very_jagged).empty());

func test_detect_vertical_in_blocks():
	var b : Blocks = BlocksScript.new();
	b.set_width(1);
	b._static_blocks = [[0, 0, 0]];
	pending();
