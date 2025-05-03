extends Node

signal request_completed(response, request_id)
signal request_failed(error, request_id)

func _on_remote_language_model_connection_request_completed(response: Variant, request_id: Variant) -> void:
	emit_signal("request_completed", response, request_id)

func _on_remote_language_model_connection_request_failed(error: Variant, request_id: Variant) -> void:
	emit_signal("request_failed", error, request_id)

func _on_local_language_model_connection_request_completed(response: Variant, request_id: Variant) -> void:
	emit_signal("request_completed", response, request_id)

func _on_local_language_model_connection_request_failed(error: Variant, request_id: Variant) -> void:
	emit_signal("request_failed", error, request_id)
