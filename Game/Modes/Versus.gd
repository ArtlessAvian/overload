extends Node2D

# TODO: Make not crude.

var boards;

func _ready():
	self.boards = [];
	for child in self.get_children():
		if child.name.begins_with("Board"):
			boards.append(child);

#
#var temp = 0;
#func _physics_process(delta):
#	temp += delta;
#	for _i in range(temp/5):sssk
#		temp -= 5;
#		for board in boards:
#			board.get_node("Blocks").receive_garbage(5)

func _on_Board_clear(board, chain, combo, _garbage):
	for b in boards:
		if board != b:
			b.garbage_inbox += int(chain > 1) * 6 + (combo-3);
	$Label.text = str($"Board".garbage_inbox);

func _on_Board_lost(board):
	boards.erase(board);
	if len(boards) == 1:
		print("someone is winnr")