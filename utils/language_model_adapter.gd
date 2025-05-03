extends Node
class_name LanguageModelAdapter

signal request_completed(response, request_id)
signal request_failed(error, request_id)

# Global switch to determine which connection to use
@onready var run_locally: bool = Globals.local
@onready var remote_connection = $RemoteLanguageModelConnection
@onready var local_connection = $LocalLanguageModelConnection

func generate(request):
	if run_locally:
		print("Using local connection")
		return local_connection.generate(request)
	else:
		print("Using remote connection")
		print("Request body: ", request.as_json_string())
		return remote_connection.generate(request)

# Create a request appropriate for the current connection type
func create_request() -> LanguageModelRequest:
	var req = LanguageModelRequest.new(run_locally)
	print("Created request with is_local=", req.is_local)
	return req

# Pass-through for static methods
static func parse_llm_response(response_text: String) -> String:
	# Use the remote connection's implementation
	return OpenRouterModelConnection.parse_llm_response(response_text)

func _on_remote_language_model_connection_request_completed(response: Variant, request_id: Variant) -> void:
	print("Remote connection request completed: ", request_id)
	emit_signal("request_completed", response, request_id)

func _on_remote_language_model_connection_request_failed(error: Variant, request_id: Variant) -> void:
	print("Remote connection request failed: ", error)
	emit_signal("request_failed", error, request_id)

func _on_local_language_model_connection_request_completed(response: Variant, request_id: Variant) -> void:
	print("Local connection request completed: ", request_id)
	emit_signal("request_completed", response, request_id)

func _on_local_language_model_connection_request_failed(error: Variant, request_id: Variant) -> void:
	print("Local connection request failed: ", error)
	emit_signal("request_failed", error, request_id)
