extends Node2D

#func _ready():

func _process(_delta):
	for i in range(self.get_child_count()):
#		if i <= $"..".garbage_inbox:
		self.get_child(i).visible = i < $"..".garbage_inbox;
