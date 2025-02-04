extends Control

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", -100, 1)
	tween.tween_callback(queue_free)
