extends TileMap
# Always a child of a child of Blocks

# Kinda RAII?

var y_offset = 0;
var to_explode = [];
var to_explode_copy = [];
var time = 0;
var effects = [];
var chain = 0;

# TOOD: Split model and view!

func initialize():
	to_explode = self.get_used_cells();
	to_explode_copy = to_explode.duplicate(false)
	to_explode.invert();
	effects.append($"Particles2D");
	while len(effects) <= len(to_explode)-1:
		var temp = $"Particles2D".duplicate();
		effects.append(temp);
		self.add_child(temp);
	
	var combo = len(to_explode);
	if (chain != 1):
		$"HBoxContainer/Chain/Label".text = "x" + str(chain);
	else:
		$"HBoxContainer/Chain".free()
	if (combo > 3):
		$"HBoxContainer/Combo/Label".text = str(combo);
	else:
		$"HBoxContainer/Combo".free()
	$"HBoxContainer".rect_position = self.map_to_world(to_explode[-1]) + self.cell_size/2;
	$"HBoxContainer".rect_position -= $"HBoxContainer".rect_size / 2;

func _process(delta):
	var speed = 20 * (0.2 - time);
	
	$"HBoxContainer".rect_position.y -= delta * self.cell_size.y * speed;
	$"HBoxContainer".modulate.a *= 0.95;

func _physics_process(delta):
	time += delta;
	if len(to_explode) != 0:
		# TODO: Move to process
		# Physics Process should only handle the model.
		while time >= $"../../..".explode_interval and not to_explode.empty():
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
				assert(self.get_blocks().board[block.x][y] == $"../../..".CLEARING);
				self.get_blocks().make_faller_column(block.x, y+1, chain + 1);
				
				self.get_blocks().board[block.x][y] = get_cellv(block);
				self.get_blocks().chain_checker[block.x][y] = chain+1;
			
			self.queue_free();

func true_raise():
	y_offset += 1;

# Parenting
func get_blocks():
	return $"../..";