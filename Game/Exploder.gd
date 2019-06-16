extends TileMap
# Kinda RAII?

var y_offset = 0;
var exploder_id;
var to_explode = [];
var to_explode_copy = [];
var time = 0;
var effects = [];
var chain = 0;

func initialize():
	to_explode = self.get_used_cells();
	to_explode_copy = to_explode.duplicate(false)
	to_explode.invert();
	effects.append($"Particles2D");
	for i in range(len(to_explode)-1):
		var temp = $"Particles2D".duplicate();
		effects.append(temp);
		self.add_child(temp);

	$"Label".text = str(chain);
	$"Label".rect_position = self.map_to_world(to_explode[-1]);
	
func _physics_process(delta):
	time += delta;
	if len(to_explode) != 0:
		while (time >= $"../../..".explode_interval):
			time -= $"../../..".explode_interval;
			var thing = to_explode.pop_back();
			var color = get_cellv(thing);
			
			if (color != $"../../..".GARBAGE):
				self.set_cellv(thing, -1);
			else:
#				self.set_cellv(thing, randi() % 1);
				self.set_cellv(thing, randi() % $"../../..".color_count);
			
			var effect = effects.pop_back();
			effect.modulate.r = cos((color/5.0) * 2 * PI)/2 + 0.5;
			effect.modulate.g = cos((color/5.0 - 1/3.0) * 2 * PI)/2 + 0.5;
			effect.modulate.b = cos((color/5.0 - 2/3.0) * 2 * PI)/2 + 0.5;
			effect.position = self.map_to_world(thing);
			effect.position += self.cell_size * 0.5;
			effect.emitting = true;
			effect.get_child(0).play();
	else:
		if (time >= $"../../..".explode_pause):
			for block in to_explode_copy:
				var y = -block.y-1 + y_offset;
#				print($"../..".board[block.x][y])
				assert($"../..".board[block.x][y] == $"../../..".CLEARING);
				$"../..".make_faller_column(block.x, y+1, chain + 1);
				
#				var overhang = false
#				for i in range(y+1, len($"../..".board[block.x])):
#					if $"../..".board[block.x][i] in [5, -1]:
#						overhang = true;
#						break;
#				if overhang:
				$"../..".board[block.x][y] = get_cellv(block);
				$"../..".chain_checker[block.x][y] = chain+1;
#				else:
#					$"../..".board[block.x].remove(y);
#					$"../..".chain_checker[block.x].remove(y);
#				$"../..".board[block.x][-block.y-1] = 3;
#			$"../..".finish_clearing.append(self.exploder_id);
			self.queue_free();

func true_raise():
	y_offset += 1;