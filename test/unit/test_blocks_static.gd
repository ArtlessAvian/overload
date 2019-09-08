extends "res://addons/GUT/test.gd"

var BlocksScript = load("res://board/blocks/BlocksModel.gd");
var b : Blocks = BlocksScript.new();

func test_detect_in_a_row():
	assert_eq(b.detect_in_a_row([]), []);
	assert_eq(b.detect_in_a_row([0]), []);
	assert_eq(b.detect_in_a_row([0, 0]), []);
	assert_eq(b.detect_in_a_row([0, 0, 0]), [0, 1, 2]);
	assert_eq(b.detect_in_a_row([0, 0, 0, 0]), [0, 1, 2, 3]);
	assert_eq(b.detect_in_a_row([0, 0, 0, 0, 0]), [0, 1, 2, 3, 4]);
	assert_eq(b.detect_in_a_row([1, 0, 0, 0, 1]), [1, 2, 3]);
	assert_eq(b.detect_in_a_row([1, 1, 1, 0, 0, 0]), [0, 1, 2, 3, 4, 5]);

func test_detect_in_jagged():
	# Not enough blocks
	assert_eq(b.detect_in_jagged([]), []);
	assert_eq(b.detect_in_jagged([[]]), []);
	assert_eq(b.detect_in_jagged([[], [], [], [], [], []]), []);
	assert_eq(b.detect_in_jagged([[0]]), []);
	assert_eq(b.detect_in_jagged([[0, 0]]), []);
	assert_eq(b.detect_in_jagged([[0], [0]]), []);

	# Direct Success
	assert_eq(b.detect_in_jagged([[0, 0, 0]]), [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2)]);
	assert_eq(b.detect_in_jagged([[0], [0], [0]]), [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)]);

	# Offset
	assert_eq(b.detect_in_jagged([[1, 0, 0, 0]]), [Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)]);
	assert_eq(b.detect_in_jagged([[1], [0, 0, 0]]), [Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)]);
	assert_eq(b.detect_in_jagged([[1], [0], [0], [0]]), [Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)]);
	assert_eq(b.detect_in_jagged([[1, 0], [2, 0], [3,0]]), [Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)]);

	var big_checker = [];
	for i in range(20):
		big_checker.append([]);
		for j in range(20):
			big_checker[i].append((i + j) % 2);
	assert_eq(b.detect_in_jagged(big_checker), []);

	var very_jagged = [];
	for i in range(20):
		very_jagged.append([]);
		for j in range((i % 3) * 10):
			very_jagged[i].append((i + j) % 6);
	assert_eq(b.detect_in_jagged(very_jagged), []);

func test_random_with_bans_correct_range():
	var sample = [];
	for i in range(100):
		sample.append(b.random_with_bans(2, []));
	assert_true(0 in sample);
	assert_true(1 in sample);
	assert_false(2 in sample);

func test_random_with_bans_correct_range_w_ban():
	var sample = [];
	for i in range(100):
		sample.append(b.random_with_bans(3, [0]));
	assert_false(0 in sample);
	assert_true(1 in sample);
	assert_true(2 in sample);
	assert_false(3 in sample);

func test_random_with_bans_banning():
	for ban in range(6):
		for other_ban in range(ban+1):
			var ban_array = [];
			ban_array.append(ban);
			if other_ban != ban:
				ban_array.append(other_ban);
			
			var sample = []
			for i in range(1000):
				sample.append(b.random_with_bans(6, ban_array));
			
			assert_false(ban in sample);
			if other_ban != ban:
				assert_false(other_ban in sample);