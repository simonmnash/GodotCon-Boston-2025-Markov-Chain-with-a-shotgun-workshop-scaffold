extends Resource
class_name TimeLapse

@export var time_elapsed : int
@export var time_lapse_history : String
@export var population_change_in_millions : int
@export var technology_level_change : int
@export var resource_richness_change : int
@export var new_overview : String

const PROPERTY_DESCRIPTIONS := {
	"time_elapsed": "Time elapsed in years",
	"time_lapse_history": "Concise 1-2 sentence description of the history of the planet over the time lapse. Nothing much happened is a perfectly fine description.",
	"new_overview": "Concise 2-3 sentance note that combines the time_lapse_history with the planet_overview.",
	"population_change_in_millions": "Change in the estimated sentient population of the planet (in millions) over the period of the time lapse",
	"technology_level_change": "A number (generally between -1 and 1 - but can be larger or smaller) representing the change in the technology available on the planet over the period of the time lapse (total scale is 0-5, 5 should be almost impossible to reach).",
	"resource_richness_change": "A number (generally between -1 and 1 - but can be larger or smaller) representing the change in the wealth available on the planet over the period of the time lapse (total scale is 0-10, 10 should be almost impossible to reach)."
}

# Returns a JSON schema for TimeLapse resource using reflection
static func get_time_lapse_schema() -> Dictionary:
	return SchemaGenerator.schema(TimeLapse.new())

# Serializes this resource to a JSON-compatible dictionary
func to_json() -> Dictionary:
	return SchemaGenerator.json_dict(self)
	
# Creates a TimeLapse instance from JSON data that matches the schema
static func from_json(json_data, time_in_years : int) -> TimeLapse:
	var default_values = {
		"time_elapsed": time_in_years,
		"time_lapse_history": "Nothing Happened.",
		"new_overview": "",
		"population_change_in_millions": 0,
		"technology_level_change": 0,
		"resource_richness_change": 0
	}
	
	var time_lapse = SchemaGenerator.from_json(json_data, TimeLapse, default_values) as TimeLapse
	time_lapse.time_elapsed = time_in_years  # Ensure this is set
	return time_lapse
