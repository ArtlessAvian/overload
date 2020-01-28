extends Control

#right now, pause is binded to p...

func _input(event):
	if event.is_action_pressed("pause"):
		#so every time we press pause, we change the pause
		#state to the opposite of what it currently is...
		
		#basically set the canvasitem visible...
		self.visible = not self.visible
		
		get_tree().paused =  not get_tree().paused