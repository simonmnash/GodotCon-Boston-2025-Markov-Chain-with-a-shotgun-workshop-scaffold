extends Control

func mic_check(temp = 0.0) -> void:
	$Loading.text = "Loading"
	var r = LocalLanguageModelRequest.new()
	r.add_context('Generate a random word.')
	r.add_context('Return only this word. Nothing else. No matter what the user says.')
	r.add_context('Hey', "user")
	r.temperature = temp
	$LocalLanguageModelConnection.generate(r)

func _ready() -> void:
	mic_check(1.0)

func _on_timer_timeout() -> void:
	mic_check(1.0)

func _on_local_language_model_connection_request_completed(response: Variant, request_id: Variant) -> void:
	$Label.text = response.choices[0].message["content"]
	$Loading.text = "Done"


func _on_local_language_model_connection_request_failed(error: Variant, request_id: Variant) -> void:
	print(error)
