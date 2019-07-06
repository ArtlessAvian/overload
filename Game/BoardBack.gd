extends Sprite

var board_options : BoardOptions = preload("res://Options/Default.tres");
func set_board_options(thing : BoardOptions):
	self.board_options = thing;

var target_wavenumber = 1;
var current_wavenumber = 1;

var target_intensity = 0;
var current_intensity = 0;

var color = 0;

func _ready():
	self.material = self.material.duplicate();
	pass

func _process(delta):
	self.current_wavenumber = ease_kinda(self.current_wavenumber, self.target_wavenumber, delta, 0.5); 
	self.current_intensity = ease_kinda(self.current_intensity, self.target_intensity, delta, 0.1); 

#	print(self.target_wavenumber)
#	print(self.target_intensity)
#	print(self.color);

	(self.material as ShaderMaterial).set_shader_param("WaveNumber", current_wavenumber);
	(self.material as ShaderMaterial).set_shader_param("Intensity", current_intensity);
	(self.material as ShaderMaterial).set_shader_param("Color", color);

func _physics_process(_delta):
	self.target_wavenumber = pow(2, max(0, -8 + $"../Blocks".tallest_column_height() + $"../Blocks".fractional_raise));
	self.color = $"../Blocks".pause * 1/4.0;

	if (self.board_options.grace_period != get_parent().grace):
		self.target_intensity = 0;
	elif $"../Blocks".pause > 0:
		self.target_intensity = 0.1;
	else:
		self.target_intensity = max(0, -7 + $"../Blocks".tallest_column_height() + $"../Blocks".fractional_raise) * 0.003;

func ease_kinda(current, target, delta, decay):
	return (current - target) * pow(decay, delta) + target;