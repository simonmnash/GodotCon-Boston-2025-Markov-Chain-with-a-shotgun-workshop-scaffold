extends Node

# Workshop Note : Don't do this in production - keep your API key on a server.
var api_key : String = ""
@export var local : bool = false

func _ready():
	if not local:
		var file = FileAccess.open('res://utils/api_key.txt', FileAccess.READ)
		var content = file.get_as_text()
		api_key = content.strip_edges()
		assert(len(api_key) > 0)
