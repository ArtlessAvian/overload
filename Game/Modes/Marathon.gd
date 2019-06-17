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
	$"Board/Blocks".set_physics_process(false);
	$"AnimationPlayer".play("Start");

func start_boards():
	$"Board/Blocks".set_process(true);
	$"Board/Blocks".set_physics_process(true);

func _process(delta):
	$Grace.text = str($"Board/Blocks".grace);

func _on_Board_chain(chain):
	for i in range(chain - len(chains)):
		chains.append(0);
	chains[chain - 1] += 1;
	print(chains)
	points += pow(2, chain-1) * 500;
	$Points.text = str(points);

func _on_Board_combo(combo):
	for i in range(combo - 2 - len(combos)):
		combos.append(0);
	combos[combo - 3] += 1;
	print(combos)
	points += 100 * combo;
	$Points.text = str(points);

func _on_Board_lost():
	$"AnimationPlayer".play("Lose");