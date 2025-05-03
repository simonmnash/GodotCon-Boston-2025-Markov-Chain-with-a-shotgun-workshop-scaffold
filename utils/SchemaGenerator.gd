extends Object
class_name SchemaGenerator

const _TYPE_MAP := {
	TYPE_BOOL:    "boolean",
	TYPE_STRING:  "string",
	TYPE_INT:     "integer",
	TYPE_FLOAT:   "number",
	TYPE_COLOR:   "string", # emitted as hex strings
}

static func _is_editor_prop(prop: Dictionary) -> bool:
	# Enumerate @export vars while skipping built-in properties and private properties
	if prop.name in ["resource_local_to_scene", "resource_path", "resource_name", "script"] or prop.name.begins_with("_"):
		return false
	
	# Only include properties that are exposed to the editor
	return (prop.usage & PROPERTY_USAGE_EDITOR) != 0
	
static func _to_hex(c: Color) -> String:
	return "#" + c.to_html(false)

static func json_dict(res: Resource) -> Dictionary:
	var result := {}
	
	for p in res.get_property_list():
		if not _is_editor_prop(p):
			continue
			
		var val = res.get(p.name)
		
		# Handle special types
		if p.type == TYPE_COLOR:
			val = _to_hex(val)
			
		result[p.name] = val
	
	return result

static func schema(res: Resource) -> Dictionary:
	var schema := {
		"type": "object",
		"properties": {},
		"required": [],
		"additionalProperties": false
	}
	
	for p in res.get_property_list():
		if not _is_editor_prop(p):
			continue
		
		# Get JSON type for this property
		var json_type = _TYPE_MAP.get(p.type, "string")
		var prop_schema := {"type": json_type}
		
		# Try to pull description from hint_string/tooltips
		if p.has("hint_string") and String(p.hint_string) != "":
			prop_schema["description"] = String(p.hint_string)
		# Fallback to constant dictionary
		elif res.get_script().has_source_code() and "PROPERTY_DESCRIPTIONS" in res and res.PROPERTY_DESCRIPTIONS.has(p.name):
			prop_schema["description"] = res.PROPERTY_DESCRIPTIONS[p.name]
		
		# Add helpful description for Color if not already set
		if p.type == TYPE_COLOR and not prop_schema.has("description"):
			prop_schema["description"] = "Color in hex format (e.g. #0080FF)"
		
		schema.properties[p.name] = prop_schema
		schema.required.append(p.name)
	
	return schema 

# Helper function to remove JavaScript-style comments from JSON
static func _remove_comments_from_json(json_str: String) -> String:
	var lines = json_str.split("\n")
	var result = []
	
	for line in lines:
		var comment_pos = line.find("//")
		if comment_pos != -1:
			# Only keep the part before the comment
			result.append(line.substr(0, comment_pos))
		else:
			result.append(line)
	
	return "\n".join(result)

# Parse JSON data with comment removal
static func parse_json(json_data) -> Dictionary:
	var parsed_json_data = json_data
	
	# Handle different input types
	if typeof(json_data) == TYPE_STRING:
		# Remove comments from JSON string before parsing
		print("RESPONSE")
		print(json_data)
		var cleaned_json = _remove_comments_from_json(json_data)
		print(cleaned_json)
		# Try to parse as JSON string
		var parse_result = JSON.parse_string(cleaned_json)
		if parse_result != null:
			parsed_json_data = parse_result
		else:
			push_error("Failed to parse JSON string")
			return {}
	
	# If we have an API response, extract the content
	if typeof(parsed_json_data) == TYPE_DICTIONARY and parsed_json_data.has("choices"):
		# Extract content from API response
		if parsed_json_data.has("choices") and parsed_json_data.choices.size() > 0:
			var content = parsed_json_data.choices[0].message.content
			
			# Remove comments before parsing
			content = _remove_comments_from_json(content)
			
			# Try to parse the content string
			var content_parse = JSON.parse_string(content)
			if content_parse != null:
				parsed_json_data = content_parse
			else:
				push_error("Failed to parse content JSON")
				return {}
	
	return parsed_json_data

# Generic from_json for resources
static func from_json(json_data, resource_type, default_values := {}) -> Resource:
	var res = resource_type.new()
	var parsed_data = parse_json(json_data)
	
	if parsed_data.is_empty():
		return res
		
	# Apply properties based on the parsed data
	for prop in res.get_property_list():
		if not _is_editor_prop(prop):
			continue
			
		if parsed_data.has(prop.name):
			res.set(prop.name, parsed_data.get(prop.name))
		elif default_values.has(prop.name):
			res.set(prop.name, default_values.get(prop.name))
	
	return res 
