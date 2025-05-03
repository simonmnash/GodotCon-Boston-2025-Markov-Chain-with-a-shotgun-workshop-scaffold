extends Control

@export var planet_cache : Array[Planet]
@export var generation_target : Planet
@export var time_lapse_target : TimeLapse
const unknown_planet = preload("res://Part 1 - Shader Control/Planet/Planets/UndiscoveredPlanet.tres")
var loading = false

func travel_to_new_planet():
	if not loading:
		loading = true
		var r = %PlanetGenerator.create_request()
		r.add_context('Invent a new planet. The user will provide a vauge overview, and you will invent something new that fits in with the universe. Avoid general or vague descriptions.')
		r.add_context('Your output should be an instance of a JSON object following the schema below')
		r.add_context(JSON.stringify(generation_target.get_planet_schema()))
		r.add_context('Nearby Planets:')
		for p in planet_cache:
			r.add_context("Existing Planet: " + p.planet_name + "-" + p.planet_overview)
		r.add_context('Generate a new planet. Limit description to bare bones geography and ecosystem. Be very intentional about the name of the planet.', "user")
		r.temperature = 0.8
		r.response_format = generation_target.get_planet_schema()
		%PlanetGenerator.generate(r)

func time_lapse(years : int):
	if not loading:
		loading = true
		var r = %TimeStepper.create_request()
		r.add_context('You are simulating the history of a planet. You should almost never change the technology level or resource richness.')
		r.add_context('Your output should be an instance of a JSON object following the schema below')
		r.add_context(JSON.stringify(time_lapse_target.get_time_lapse_schema()))
		r.add_context(planet_cache[-1].to_summary())
		r.add_context('Simulate a ' + str(years) + ' year period of history of the planet named' + planet_cache[-1].planet_name + ".", "user")
		r.temperature = 0.4
		r.response_format = time_lapse_target.get_time_lapse_schema()
		%TimeStepper.generate(r)

func _ready() -> void:
	travel_to_new_planet()

func _on_random_warp_pressed() -> void:
	%PlanetView.planet_data = unknown_planet
	travel_to_new_planet()

func _on_time_lapse_button_pressed() -> void:
	time_lapse(100)

func _on_planet_generator_request_completed(response: Variant, request_id: Variant) -> void:
	print(response)
	var response_content = response.choices[0].message.content
	var parsed_response_content = %PlanetGenerator.parse_llm_response(response_content)
	var new_planet = Planet.from_json(parsed_response_content)
	%PlanetView.planet_data = new_planet
	%Name.text = new_planet.planet_name
	%Population.text = "Population: " + str(new_planet.population) + " Million"
	%TechnologyLevel.text = "Technology Level: " + str(new_planet.technology_level)
	%ResourceRichness.text = "Resource Value: " + str(new_planet.resource_richness)
	%Description.text = new_planet.planet_overview
	planet_cache.append(new_planet)
	loading = false

func _on_planet_generator_request_failed(error: Variant, request_id: Variant) -> void:
	print(error)

func _on_time_stepper_request_completed(response: Variant, request_id: Variant) -> void:
	var response_content = response.choices[0].message.content
	var parsed_content = %TimeStepper.parse_llm_response(response_content)
	var tl = TimeLapse.from_json(parsed_content, 1)
	%PlanetView.planet_data.apply_time_lapse(tl)
	%Population.text = "Population: " + str(%PlanetView.planet_data.population) + " Million"
	%TechnologyLevel.text = "Technology Level: " + str(%PlanetView.planet_data.technology_level)
	%ResourceRichness.text = "Resource Value: " + str(%PlanetView.planet_data.resource_richness)
	%Description.text = %PlanetView.planet_data.planet_overview
	loading = false

func _on_time_stepper_request_failed(error: Variant, request_id: Variant) -> void:
	print(error)
