extends Object
class_name LanguageModelRequest

var models = ["qwen/qwen3-0.6b-04-28:free", "mistralai/ministral-3b", "mistralai/mistral-large-2411"]
var context: Array[Dictionary] :
	set(v) :
		for msg in v:
			assert(msg.get('role') in ['system', 'user', 'assistent'])
		context = v
		
var model: String = models[0]
var temperature: float = 0.7
var max_tokens: int = 1024
var response_format = null
var tools: Array = []
var tool_choice: String = "none"

func _init() -> void:
	for msg in context:
		assert(msg.get('role') in ['system', 'user', 'assistent'])
	assert(temperature <= 1.0)
	assert(temperature >= 0.0)
	assert(max_tokens < 2048)
	assert(tool_choice in ['none', 'auto'])

func as_json_string():
	var body = JSON.stringify({
		"model": self.model,
		"messages": self.context,
		"response_format": self.response_format,
		"tools": self.tools,
		"tool_choice": self.tool_choice,
		"temperature": self.temperature,
		"max_tokens": self.max_tokens
	})
	return body

func add_context(content : String, role : String = "system") -> Array[Dictionary]:
	assert(role in ['system', 'user', 'assistent'])
	context.append({'role': role, 'content': content})
	return context
