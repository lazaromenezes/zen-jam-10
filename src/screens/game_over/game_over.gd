extends Node2D

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	
	var target_position = viewport_size / 2 - %FloatingBoard.size / 2
	var initial_position = target_position + Vector2(0, viewport_size.y + 100)
	
	%FloatingBoard.global_position = initial_position
	
	var tween = create_tween()
	tween.tween_property(%Separator, 'self_modulate:a', 1, 0.5)
	tween.parallel().tween_property(%FloatingBoard, 'global_position', target_position, 1.5)
	tween.tween_callback(%FloatingBoard.select_first_option)
