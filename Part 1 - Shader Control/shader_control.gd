extends Control

@export var  planet_cache : Array[Planet] = []
@export var generation_target : Planet
const unknown_planet = preload("res://Part 1 - Shader Control/Planet/Planets/UndiscoveredPlanet.tres")

var loading = false

func travel_to_new_planet():
	if not loading:
		loading = true
		var r = %LanguageModelAdapter.create_request()
		r.add_context('Invent a new planet. The user will provide a vauge overview, and you will invent something new that fits in with the universe. Avoid general or vague descriptions.')
		r.add_context('Your output should be an instance of a JSON object following the schema below')
		r.add_context(JSON.stringify(generation_target.get_planet_schema()))
		r.add_context('Nearby Planets:')
		for p in planet_cache:
			r.add_context("Existing Planet: " + p.planet_name + "-" + p.planet_overview)
		r.add_context('Generate a new planet. Limit description to bare bones geography and ecosystem. Be very intentional about the name of the planet.', "user")
		r.temperature = 1.0
		r.response_format = generation_target.get_planet_schema()
		%LanguageModelAdapter.generate(r)

func _ready() -> void:
	travel_to_new_planet()

func _on_random_warp_pressed() -> void:
	%PlanetView.planet_data = unknown_planet
	travel_to_new_planet()


func _on_language_model_adapter_request_completed(response: Variant, request_id: Variant) -> void:
	var response_content = response.choices[0].message.content
	var parsed_response_content = %LanguageModelAdapter.parse_llm_response(response_content)
	var new_planet = Planet.from_json(parsed_response_content)
	%PlanetView.planet_data = new_planet
	%Name.text = new_planet.planet_name
	%Population.text = "Population: " + str(new_planet.population) + " Million"
	%Description.text = new_planet.planet_overview
	planet_cache.append(new_planet)
	loading = false

func _on_language_model_adapter_request_failed(error: Variant, request_id: Variant) -> void:
	print(error)
