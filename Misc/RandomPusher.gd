extends Node

func _physics_process(_delta):
	if (randf() > 0.9):
		Input.action_press("rand_down");
	elif (randf() > 0.9):
		Input.action_press("rand_up");
	if (randf() > 0.9):
		Input.action_press("rand_left");
	elif (randf() > 0.888888):
		Input.action_press("rand_right");
	if (randf() > 0.3):
		Input.action_press("rand_swap");
	if (randf() > 0.9999):
		Input.action_press("rand_raise");