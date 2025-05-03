extends Resource
class_name Planet

@export_category("Basic Planet Attributes")
@export var planet_name : String
@export var planet_overview : String
@export var population : int
@export var technology_level : int
@export var resource_richness : int
@export_category("Color Scheme")
@export var primary_color : Color
@export var secondary_color : Color
@export var cloud_color : Color
@export var primary_secondary_balance : float

const PROPERTY_DESCRIPTIONS := {
	"planet_name": "A name of the planet",
	"planet_overview": "One-two sentence encyclopedia topline of the planet. Be specific, inventive, and curt when referring to events, features, or locations on the planet. Pick one specific thing rather than going over details.",
	"population": "Estimated population of the planet (in millions)",
	"technology_level": "A number between 0 and 5 describing the scale of technology available to the population of the planet.",
	"resource_richness": "A number between 0 and 10 describing the value of the resources available on the planet.",
	"primary_color": "Primary surface color in hex format (e.g. #0080FF)",
	"secondary_color": "Secondary surface color in hex format",
	"cloud_color": "Cloud color in hex format",
	"primary_secondary_balance": "Number between 0.5 (half primary) and 1.0 (all primary)"
}

# Returns a JSON schema for Planet resource using reflection
static func get_planet_schema() -> Dictionary:
	return SchemaGenerator.schema(Planet.new())

# Serializes this resource to a JSON-compatible dictionary
func to_json() -> Dictionary:
	return SchemaGenerator.json_dict(self)

# Creates a Planet instance from JSON data that matches the schema
static func from_json(json_data) -> Planet:
	var default_values = {
		"planet_name": "",
		"planet_overview": "",
		"population": 0,
		"technology_level": 0,
		"resource_richness": 0,
		"primary_secondary_balance": 0.5
	}
	
	return SchemaGenerator.from_json(json_data, Planet, default_values) as Planet

# Generate a random seed value between 0-50 from planet name and overview
func generate_seed() -> float:
	var combined_string = planet_name + planet_overview
	var hash_value = combined_string.hash()
	return abs(hash_value) % 10000 / 200.0
	
func apply_time_lapse(time_lapse : TimeLapse):
	self.planet_overview = time_lapse.new_overview
	self.population += time_lapse.population_change_in_millions
	self.population = clampi(self.population, 0, 10000)
	self.technology_level += time_lapse.technology_level_change
	self.technology_level = clampi(self.technology_level, 0, 5)
	self.resource_richness += time_lapse.resource_richness_change
	self.resource_richness = clampi(self.resource_richness, 0, 10)
