extends "res://addons/GUT/test.gd"

const EXPLODER_SCRIPT = "res://board/dynamic_blocks/exploder/ExploderModel.gd";
const EXPLODER_PRELOAD = preload(EXPLODER_SCRIPT);

func test_initable():
	assert_not_null(EXPLODER_PRELOAD.new([], []));

func test_exploders_delete_in_array():
	var dummy_array = [[0, 1], [2, 3]];
	var e : Exploder = EXPLODER_PRELOAD.new([Vector2(0, 0), Vector2(1, 1)], dummy_array);
	assert_eq(dummy_array, [[6, 1], [2, 6]]);
	simulate(e, 1, 10000);
	assert_eq(dummy_array, [[-1, 1], [2, -1]]);

func test_exploders_signals_done():
	var e : Exploder = EXPLODER_PRELOAD.new([], []);
	watch_signals(e);
	assert_signal_not_emitted(e, "done_exploding");
	simulate(e, 1, 0);
	assert_signal_not_emitted(e, "done_exploding");
	simulate(e, 1, 1000);
	assert_signal_emitted(e, "done_exploding", [e, [], []]);

func test_exploders_frees_self():
	var e : Exploder = EXPLODER_PRELOAD.new([], []);
	assert_false(e.is_queued_for_deletion());
	simulate(e, 1, 0);
	assert_false(e.is_queued_for_deletion());
	simulate(e, 1, 1000);
	assert_true(e.is_queued_for_deletion());
