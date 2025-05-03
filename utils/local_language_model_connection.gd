extends Node
class_name LocalLanguageModelConnection

signal request_completed(response, request_id)
signal request_failed(error, request_id)

const API_BASE_URL = "http://localhost:11434/api"

var active_requests = {}
var request_counter = 0

# Create a new HTTP request
func _create_request(timeout : float = 30.0) -> HTTPRequest:
	var http_request = HTTPRequest.new()
	http_request.timeout = timeout # 30 second timeout
	add_child(http_request)
	return http_request

# Configure headers for the request
func _configure_headers() -> PackedStringArray:
	var headers = PackedStringArray([
		"Content-Type: application/json"
	])
	return headers

# Main function to generate a response from the language model
func generate(language_model_request : LanguageModelRequest):
	var request_id = request_counter
	request_counter += 1
	
	var http_request = _create_request()
	http_request.request_completed.connect(_on_request_completed.bind(request_id))
	active_requests[request_id] = http_request
	
	var body = _prepare_ollama_request_body(language_model_request)
	
	var headers = _configure_headers()
	var endpoint = "/generate"  # Use generate endpoint for non-chat completions
	
	if language_model_request.context.size() > 0:
		endpoint = "/chat"  # Use chat endpoint if we have a conversation context
	
	var error = http_request.request(API_BASE_URL + endpoint, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		active_requests.erase(request_id)
		emit_signal("request_failed", "Failed to make request: " + str(error), request_id)
		return -1
		
	return request_id

# Prepare the request body for Ollama API
func _prepare_ollama_request_body(language_model_request : LanguageModelRequest) -> String:
	if language_model_request.context.size() > 0:
		# Using /chat endpoint
		var body = {
			"model": language_model_request.model,
			"messages": language_model_request.context,
			"stream": false,
			"options": {
				"temperature": language_model_request.temperature
			}
		}
		
		# Add max tokens as num_predict in options
		if language_model_request.max_tokens > 0:
			body["options"]["num_predict"] = language_model_request.max_tokens
		
		# Add format if specified
		if language_model_request.response_format != null:
			# Handle different format specifications between APIs
			if typeof(language_model_request.response_format) == TYPE_DICTIONARY:
				if language_model_request.response_format.has("type") and language_model_request.response_format.get("type") == "json_object":
					# OpenRouter JSON mode maps to Ollama's simple "json" format
					body["format"] = "json"
				elif language_model_request.response_format.has("type") and language_model_request.response_format.get("type") == "json_schema":
					# OpenRouter JSON schema mode maps to Ollama's format object with schema
					body["format"] = language_model_request.response_format.get("schema", {})
				else:
					# Pass the format as is for custom schemas
					body["format"] = language_model_request.response_format
			else:
				# Direct format assignment (like "json")
				body["format"] = language_model_request.response_format
		
		# Add tools if specified
		if language_model_request.tools.size() > 0:
			body["tools"] = language_model_request.tools
			
		return JSON.stringify(body)
	else:
		# Using /generate endpoint
		var body = {
			"model": language_model_request.model,
			"prompt": "", # Will be set in calling code
			"stream": false,
			"options": {
				"temperature": language_model_request.temperature
			}
		}
		
		# Add max tokens as num_predict in options
		if language_model_request.max_tokens > 0:
			body["options"]["num_predict"] = language_model_request.max_tokens
		
		# Add format if specified
		if language_model_request.response_format != null:
			# Handle different format specifications between APIs
			if typeof(language_model_request.response_format) == TYPE_DICTIONARY:
				if language_model_request.response_format.has("type") and language_model_request.response_format.get("type") == "json_object":
					# OpenRouter JSON mode maps to Ollama's simple "json" format
					body["format"] = "json"
				elif language_model_request.response_format.has("type") and language_model_request.response_format.get("type") == "json_schema":
					# OpenRouter JSON schema mode maps to Ollama's format object with schema
					body["format"] = language_model_request.response_format.get("schema", {})
				else:
					# Pass the format as is for custom schemas
					body["format"] = language_model_request.response_format
			else:
				# Direct format assignment (like "json")
				body["format"] = language_model_request.response_format
			
		return JSON.stringify(body)

# Handle completed requests
func _on_request_completed(result, response_code, headers, body, request_id):
	var http_request = active_requests[request_id]
	active_requests.erase(request_id)
	http_request.queue_free()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("request_failed", "Request failed with code: " + str(result), request_id)
		return
		
	if response_code != 200:
		emit_signal("request_failed", "API returned error code: " + str(response_code) + " with body: " + body.get_string_from_utf8(), request_id)
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		emit_signal("request_failed", "Failed to parse JSON response", request_id)
		return
	
	# Transform Ollama response format to match OpenRouter format for compatibility
	var transformed_response = _transform_response_format(json)
	emit_signal("request_completed", transformed_response, request_id)

# Transform Ollama response format to match OpenRouter
func _transform_response_format(ollama_response: Dictionary) -> Dictionary:
	var response = {}
	
	# Check if this is a chat response or generate response
	if ollama_response.has("message"):
		# Chat API response
		response = {
			"model": ollama_response.get("model", ""),
			"created": ollama_response.get("created_at", ""),
			"choices": [
				{
					"index": 0,
					"message": {
						"role": "assistant",
						"content": ollama_response.get("message", {}).get("content", "")
					},
					"finish_reason": "stop"
				}
			]
		}
		
		# Add tool calls if present
		if ollama_response.get("message", {}).has("tool_calls"):
			response["choices"][0]["message"]["tool_calls"] = ollama_response["message"]["tool_calls"]
	else:
		# Generate API response
		response = {
			"model": ollama_response.get("model", ""),
			"created": ollama_response.get("created_at", ""),
			"choices": [
				{
					"index": 0,
					"text": ollama_response.get("response", ""),
					"finish_reason": "stop"
				}
			]
		}
	
	# Add usage information if available
	if ollama_response.has("eval_count") and ollama_response.has("prompt_eval_count"):
		response["usage"] = {
			"prompt_tokens": ollama_response.get("prompt_eval_count", 0),
			"completion_tokens": ollama_response.get("eval_count", 0),
			"total_tokens": ollama_response.get("prompt_eval_count", 0) + ollama_response.get("eval_count", 0)
		}
	
	return response

# Helper function to create a message object
func create_message(role: String, content: String) -> Dictionary:
	assert(role in ['user', 'system', 'assistant'])
	return {
		"role": role,
		"content": content
	}

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

# Extract JSON from text response
static func extract_json(text: String):
	# Try normal parsing first
	var json_result = JSON.parse_string(text)
	if json_result != null:
		return json_result
	
	# If Ollama returns a string that contains JSON but is not valid JSON itself
	# First check if response is a JSON string (common with format=json)
	if text.begins_with("{") and text.ends_with("}"):
		json_result = JSON.parse_string(text)
		if json_result != null:
			return json_result
	
	return LanguageModelConnection.extract_json(text)

# Parse LLM response similar to LanguageModelConnection
static func parse_llm_response(response_text: String) -> String:
	return LanguageModelConnection.parse_llm_response(response_text) 
