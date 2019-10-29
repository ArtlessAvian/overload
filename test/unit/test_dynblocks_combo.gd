extends "res://addons/GUT/test.gd"

var DynBlocksScript = load("res://board/dynamic_blocks/DynamicBlocksModel.gd");

func test_regular_combo():
	var b : DynamicBlocks = DynBlocksScript.new(2);
	b._static_blocks = [[0, 0, 1, 0], [9, 9, 0]];
	b._chain_storage = [[1, 1, 1, 1], [1, 1, 1]];
	
	watch_signals(b);
	b.swap(Vector2(0, 2));
	simulate(b, 1, 0);
#	print(b._static_blocks);
	
	var clears = [];
	for i in range(4):
		clears.append(Vector2(0, i));
	assert_signal_emitted_with_parameters(b, "clear", [clears, 1]);

func test_combos_sorted():
	pending();
	
func test_dropping_combo():
	var b : DynamicBlocks = DynBlocksScript.new(2);
	b._static_blocks = [[9, 0, 0, 1, 0], [1, 1]];
	b._chain_storage = [[1, 1, 1, 1, 1], [1, 1]];
	
	watch_signals(b);
#	print(b._static_blocks)
	b.swap(Vector2(0, 3));
#	print(b._static_blocks)
	assert_signal_not_emitted(b, "clear");
	simulate(b, 1, 0);
	assert_signal_not_emitted(b, "clear");
	simulate(b, 1, 1);
	assert_signal_not_emitted(b, "clear");
	simulate(b, 1, 0);
	
	var clears = [];
	for i in range(3):
		clears.append(Vector2(0, i+1));
	for i in range(3):
		clears.append(Vector2(1, i));
	assert_signal_emitted_with_parameters(b, "clear", [clears, 1])
