extends Node
class_name OpenRouterModelConnection

signal request_completed(response, request_id)
signal request_failed(error, request_id)

const API_BASE_URL = "https://openrouter.ai/api/v1"

@onready var api_key = Globals.api_key

var active_requests = {}
var request_counter = 0

func _ready():
	if not Globals.local:
		print("Remote mode: API key length: ", len(api_key))
		assert(len(api_key) > 0)

# Create a new HTTP request with proper headers
func _create_request(timeout : float = 30.0) -> HTTPRequest:
	var http_request = HTTPRequest.new()
	http_request.timeout = timeout # 30 second timeout
	add_child(http_request)
	return http_request

# Configure headers for the request
func _configure_headers() -> PackedStringArray:
	var headers = PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	])
	print("Headers configured with auth token length: ", len(api_key))
	return headers

func generate(language_model_request : LanguageModelRequest):
	var request_id = request_counter
	request_counter += 1
	
	print("Generating with remote connection, request ID: ", request_id)
	
	var http_request = _create_request()
	http_request.request_completed.connect(_on_request_completed.bind(request_id))
	active_requests[request_id] = http_request
	
	var body = language_model_request.as_json_string()
	print("Request body prepared: ", body.substr(0, 100) + "...")
	
	var headers = _configure_headers()
	var url = API_BASE_URL + "/chat/completions"
	print("Sending request to URL: ", url)
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		print("HTTP request error code: ", error)
		active_requests.erase(request_id)
		emit_signal("request_failed", "Failed to make request: " + str(error), request_id)
		return -1
		
	print("Request sent successfully with ID: ", request_id)
	return request_id

# Handle completed requests
func _on_request_completed(result, response_code, headers, body, request_id):
	print("Request completed callback - Result: ", result, ", Response code: ", response_code, ", Request ID: ", request_id)
	
	var http_request = active_requests[request_id]
	active_requests.erase(request_id)
	http_request.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Request failed with result code: ", result)
		emit_signal("request_failed", "Request failed with code: " + str(result), request_id)
		return
		
	if response_code != 200:
		var error_body = body.get_string_from_utf8()
		print("API error with code ", response_code, ": ", error_body)
		emit_signal("request_failed", "API returned error code: " + str(response_code) + " with body: " + error_body, request_id)
		return
		
	var response_text = body.get_string_from_utf8()
	print("Response received: ", response_text.substr(0, 100) + "...")
	
	var json = JSON.parse_string(response_text)
	if json == null:
		print("Failed to parse JSON response: ", response_text.substr(0, 100) + "...")
		emit_signal("request_failed", "Failed to parse JSON response", request_id)
		return
	print(response_text)
	print("Emitting request_completed signal with valid JSON")
	emit_signal("request_completed", json, request_id)

# Helper function to create a message object
func create_message(role: String, content: String) -> Dictionary:
	assert(role in ['user', 'system', 'assistant'])
	return {
		"role": role,
		"content": content
	}

# At least one of the OpenRouter Mistral-Small-3.1 providers appears to return malformed tool calls.
# These appear to be predictibly malformed.
# Utility function to find valid JSON objects in a potentially malformed string
# Returns an array of dictionaries containing the parsed objects and their positions
static func find_valid_json_objects(text: String) -> Array:
	var valid_objects = []
	var i = 0
	
	while i < len(text):
		# Look for opening brace of an object
		if text[i] == '{':
			var start_pos = i
			var nesting_level = 1
			var in_string = false
			var escape_next = false
			i += 1  # Move past the opening brace
			
			# Track nesting to find matching closing brace
			while i < len(text) and nesting_level > 0:
				var char = text[i]
				
				if escape_next:
					escape_next = false
				elif char == '\\':
					escape_next = true
				elif char == '"' and not escape_next:
					in_string = not in_string
				elif not in_string:
					if char == '{':
						nesting_level += 1
					elif char == '}':
						nesting_level -= 1
						
				i += 1
			
			# If we found a matching closing brace
			if nesting_level == 0:
				var potential_json = text.substr(start_pos, i - start_pos)
				var parse_result = JSON.parse_string(potential_json)
				
				if parse_result != null:
					valid_objects.append({
						"text": potential_json,
						"parsed": parse_result,
						"start": start_pos,
						"end": i - 1
					})
			else:
				# Unbalanced braces, move on
				i = start_pos + 1
		else:
			i += 1
	
	return valid_objects

# Try to extract valid JSON from a potentially malformed string
# Returns the parsed object if found, null otherwise
static func extract_json(text: String):
	# Try normal parsing first
	var json_result = JSON.parse_string(text)
	if json_result != null:
		return json_result
	
	# If parsing failed, try to find valid JSON objects
	var valid_objects = find_valid_json_objects(text)
	if valid_objects.size() > 0:
		# Return the last valid object found (often the most complete one)
		return valid_objects[-1].parsed
	return null

# Cancel a specific request
func cancel_request(request_id: int) -> bool:
	if active_requests.has(request_id):
		var http_request = active_requests[request_id]
		http_request.cancel_request()
		active_requests.erase(request_id)
		http_request.queue_free()
		return true
	return false

# Cancel all active requests
func cancel_all_requests() -> void:
	for request_id in active_requests:
		var http_request = active_requests[request_id]
		http_request.cancel_request()
		http_request.queue_free()
	active_requests.clear()


static func parse_llm_response(response_text: String) -> String:
	var json_content = response_text
	# Check if response is wrapped in markdown code blocks
	if response_text.begins_with("```") and response_text.ends_with("```"):
		# Find the JSON content between backticks
		var start_idx = response_text.find("\n", response_text.find("```")) + 1
		var end_idx = response_text.rfind("```")
		if start_idx > 0 and end_idx > start_idx:
			json_content = response_text.substr(start_idx, end_idx - start_idx).strip_edges()
			return json_content
		else:
			return ""
	else:
		return response_text
