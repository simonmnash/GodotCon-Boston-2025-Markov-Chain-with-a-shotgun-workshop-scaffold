extends LanguageModelRequest
class_name LocalLanguageModelRequest

var ollama_models = [
	"gemma3:1b", 
	'qwen3:0.6b',
]

func _init() -> void:
	model = ollama_models[0]
	super()
	
# Override as_json_string to adapt for Ollama format if needed
func as_json_string():
	# We don't need to override this as the LocalLanguageModelConnection 
	# will handle the format conversion with _prepare_ollama_request_body
	return super.as_json_string() 
