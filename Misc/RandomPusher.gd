extends Node

func _physics_process(delta):
	if (randf() > 0.9):
		Input.action_press("rand_up");
	if (randf() > 0.9):
		Input.action_press("rand_down");
	if (randf() > 0.9):
		Input.action_press("rand_left");
	if (randf() > 0.9):
		Input.action_press("rand_right");
	if (randf() > 0.3):
		Input.action_press("rand_swap");
	if (randf() > 0.9):
		Input.action_press("rand_raise");