extends Label

func _ready() -> void:
	text = "Line count: 0"

func _on_line_count_updated(count: int) -> void:
	text = "Line count: " + str(count)
