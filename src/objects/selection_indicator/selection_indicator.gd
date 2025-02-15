extends Container

@export var _icons: Array[Texture2D]
@export var _width_offset: int = 250

func set_placement(target: Control):
	var baloon = _icons.pick_random()
	$Left.texture = baloon
	$Right.texture = baloon
	
	var target_position := target.global_position
	var target_width = target.size.x + _width_offset
	target_position.x -= (target_width - target.size.x) / 2
	target_position.y -= (size.y - target.size.y) / 2
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.15)
	tween.parallel().tween_property(self, "size:x", target_width, 0.15)
