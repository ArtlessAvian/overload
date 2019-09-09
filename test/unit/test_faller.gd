extends "res://addons/GUT/test.gd"

const FALLER_SCRIPT = "res://board/dynamic_blocks/faller/FallerModel.gd";
const FALLER_PRELOAD = preload(FALLER_SCRIPT);

func test_initable():
	assert_not_null(FALLER_PRELOAD.new([], 0, [], []));

func test_faller_falls():
	var f : Faller = FALLER_PRELOAD.new([], 10, [], []);
	simulate(f, 10, 0.1);
	assert_almost_eq(f._y, 9.0, 0.001)

func test_faller_lands_on_nothing():
	var col : Array = [];
	var chain_col : Array = [];
	var f : Faller = FALLER_PRELOAD.new([1337], 2, col, chain_col);
	
	simulate(f, 19, 0.1);
	assert_false(f.is_queued_for_deletion());
	simulate(f, 2, 0.1);
	assert_true(f.is_queued_for_deletion());

func test_faller_lands_in_space():
	var col : Array = [0, -1, -1, -1, -1, 0];
	var chain_col : Array = [1, 1, 1, 1, 1];
	var f : Faller = FALLER_PRELOAD.new([7, 7, 7], 3, col, chain_col, 2);
	
	simulate(f, 19, 0.1);
	assert_false(f.is_queued_for_deletion());
	simulate(f, 2, 0.1);
	assert_true(f.is_queued_for_deletion());
	
func test_faller_lands_on_last():
	var col : Array = [0];
	var chain_col : Array = [1];
	var f : Faller = FALLER_PRELOAD.new([7, 7, 7], 3, col, chain_col, 2);
	
	simulate(f, 19, 0.1);
	assert_false(f.is_queued_for_deletion());
	simulate(f, 2, 0.1);
	assert_true(f.is_queued_for_deletion());

func test_faller_appends_on_nothing():
	var col : Array = [];
	var chain_col : Array = [];
	var f : Faller = FALLER_PRELOAD.new([1337], 2, col, chain_col);
	
	simulate(f, 21, 0.1);
	
	assert_eq(col, [1337]);
	assert_eq(chain_col, [1]);

func test_faller_appends_in_space():
	var col : Array = [0, -1, -1, -1, -1, 0];
	var chain_col : Array = [1, 1, 1, 1, 1];
	var f : Faller = FALLER_PRELOAD.new([7, 7, 7], 3, col, chain_col, 2);
	
	simulate(f, 21, 0.1);
	
	assert_eq(col, [0, 7, 7, 7, -1, 0]);
	assert_eq(chain_col, [1, 2, 2, 2, 1]);

func test_faller_appends_on_last():
	var col : Array = [0];
	var chain_col : Array = [1];
	var f : Faller = FALLER_PRELOAD.new([7, 7, 7], 3, col, chain_col, 2);
	
	simulate(f, 21, 0.1);

	assert_eq(col, [0, 7, 7, 7]);
	assert_eq(chain_col, [1, 2, 2, 2]);

func test_faller_tunneling_into_solid_block():
	var col : Array = [0, 0, 0]
	pending();
	
func test_faller_tunneling_into_empty_space():
	var col : Array = [-1, -1, 0]
	pending();