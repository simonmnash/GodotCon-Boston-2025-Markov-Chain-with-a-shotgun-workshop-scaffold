extends Object
class_name LanguageModelRequest

var remote_models = ["mistralai/ministral-3b"]
var local_models = ["gemma3:1b", "qwen3:0.6b"]

var context: Array[Dictionary] :
	set(v) :
		for msg in v:
			assert(msg.get('role') in ['system', 'user', 'assistant'])
		context = v
		
var model: String
var temperature: float = 0.7
var max_tokens: int = 1024
var response_format = null
var tools: Array = []
var tool_choice: String = "none"
var is_local: bool = false

func _init(local: bool = false) -> void:
	is_local = local
	# Set default model based on local/remote
	model = local_models[0] if local else remote_models[0]
	
	for msg in context:
		assert(msg.get('role') in ['system', 'user', 'assistant'])
	assert(temperature <= 1.0)
	assert(temperature >= 0.0)
	assert(max_tokens < 2048)
	assert(tool_choice in ['none', 'auto'])

func as_json_string():
	if is_local:
		# Format for Ollama - simplified version without tools and other parameters
		var body = {
			"model": self.model,
			"messages": self.context,
			"temperature": self.temperature,
			"max_tokens": self.max_tokens
		}
		
		# Add format if specified (direct format for local)
		if response_format != null:
			body["format"] = response_format
			
		return JSON.stringify(body)
	else:
		# Format for remote API with proper JSON schema wrapping
		var body = {
			"model": self.model,
			"messages": self.context,
			"tools": self.tools,
			"tool_choice": self.tool_choice,
			"temperature": self.temperature,
			"max_tokens": self.max_tokens
		}
		
		# Wrap the schema in OpenRouter format if provided
		if response_format != null:
			body["response_format"] = {
				"type": "json_schema",
				"json_schema": {
					"schema": response_format,
					"name": "response",
					"strict": true
				}
			}
		
		return JSON.stringify(body)

func add_context(content : String, role : String = "system") -> Array[Dictionary]:
	assert(role in ['system', 'user', 'assistant'])
	context.append({'role': role, 'content': content})
	return context
