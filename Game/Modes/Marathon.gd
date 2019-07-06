extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var chains = []
var combos = []
var points = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
#	$"Board/Blocks".set_process(false);
#	$"Board/Blocks"._process(0);
	$"Board".pre_round_start();

func start_boards():
	$"Board".round_start();

func _process(_delta):
	$Grace.text = str($"Board".grace);
	$Pause.text = str($"Board/Blocks".pause);

func _on_Board_clear(_board, chain, combo, _garbage):
	while len(chains) <= chain-1:
		chains.append(0);
	chains[chain - 1] += 1;
	if chain >= 2:
		chains[chain - 2] -= 1;
	points += pow(2, chain-1) * 500;
	
	while len(combos) <= combo-3:
		combos.append(0);
	combos[combo - 3] += 1;
	points += 100 * combo;
	
	$Points.text = str(points);

func _on_Board_lost(_board):
	$"Lose".text = "YOU LOSE, NERRRRD"

func _on_Board_round_ready():
	start_boards();
