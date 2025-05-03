extends Sprite2D

var scanning = 50.0

@export var planet_data : Planet : 
	set(v):
		planet_data = v
		material.set_shader_parameter("primary_color", planet_data.primary_color)
		material.set_shader_parameter("secondary_color", planet_data.secondary_color)
		material.set_shader_parameter("cloud_color", planet_data.cloud_color)
		material.set_shader_parameter("primary_bias", planet_data.primary_secondary_balance)
		material.set_shader_parameter("seed", planet_data.generate_seed())

func _ready():
	assert(planet_data != null)
	material.set_shader_parameter("primary_color", planet_data.primary_color)
	material.set_shader_parameter("secondary_color", planet_data.secondary_color)
	material.set_shader_parameter("cloud_color", planet_data.cloud_color)
	material.set_shader_parameter("primary_bias", planet_data.primary_secondary_balance)
	material.set_shader_parameter("seed", planet_data.generate_seed())
	
func _process(delta: float) -> void:
	assert(planet_data != null)
	if planet_data.planet_name == "Unknown":
		scanning += delta
		material.set_shader_parameter("seed", scanning)
