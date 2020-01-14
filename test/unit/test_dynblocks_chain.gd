extends "res://addons/GUT/test.gd"

var DynBlocksScript = load("res://board/dynamic_blocks/DynamicBlocksModel.gd");

#func debug_view_blocks(b : Blocks):
#	self.add_child(b)

func test_regular_chain():
	var b : DynamicBlocks = DynBlocksScript.new(1);
	b._static_blocks = [[0, 1, 1, 1, 0, 0]];
	b._chain_storage = [[1, 1, 1, 1, 1, 1]];
	watch_signals(b);
	
	b._queue_check = true;
	simulate(b, 1, 0); # Queued check checks.
	
	var clears = [];
	for i in range(3):
		clears.append(Vector2(0, i + 1));
	assert_signal_emitted_with_parameters(b, "clear", [clears, 1])
	
	simulate(b, 1, 3 * Exploder.EXPLODE_PERIOD + Exploder.EXPLODE_DELAY); # Exploder finishes exploding
	simulate(b, 3, 1); # Faller finishes falling
	simulate(b, 1, 0); # Queued check checks.
	
	clears.clear();
	for i in range(3):
		clears.append(Vector2(0, i));
	assert_signal_emitted_with_parameters(b, "clear", [clears, 2])

func test_massive_chain():
	var b : DynamicBlocks = DynBlocksScript.new(4);
	for i in range(10):
		for j in range(3):
			b._static_blocks[j].append(2 * i);
			b._chain_storage[j].append(1);
		for j in range(1, 4):
			b._static_blocks[j].append(2 * i + 1);
			b._chain_storage[j].append(1);
	watch_signals(b);
	
	var left_clears = [];
	var right_clears = [];
	for i in range(3):
		left_clears.append(Vector2(i, 0));
		right_clears.append(Vector2(i+1, 0));
	
	b._queue_check = true;
	for i in range(10):
		simulate(b, 1, 0); # Queued check checks.
		assert_signal_emitted_with_parameters(b, "clear", [left_clears, 2 * i + 1])
		simulate(b, 1, 3 * Exploder.EXPLODE_PERIOD + Exploder.EXPLODE_DELAY); # Exploder finishes exploding
		simulate(b, 1, 1); # Faller finishes falling

		simulate(b, 1, 0); # Queued check checks.
		assert_signal_emitted_with_parameters(b, "clear", [right_clears, 2 * i + 2])
		simulate(b, 1, 3 * Exploder.EXPLODE_PERIOD + Exploder.EXPLODE_DELAY); # Exploder finishes exploding
		simulate(b, 1, 1); # Faller finishes falling
