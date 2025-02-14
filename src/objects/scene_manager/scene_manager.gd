extends CanvasLayer

enum Scene{
	TITLE,
	MAP,
	GAME_OVER
}

@export var _scenes: Dictionary[Scene, PackedScene] = {}
@export var _ballons: Array[Texture2D]

var _spawn_position: Vector2

func _ready() -> void:
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	_spawn_position = Vector2(width, height) / 2

func transition_to(new_scene: Scene, show_transition: bool = true) -> void:
	if show_transition:
		var sprite := _spawn_sprite()
	
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(20, 20), 0.5)
		tween.tween_callback(func(): _switch_scene(new_scene)).set_delay(0.1)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.5)
		tween.tween_callback(func(): sprite.queue_free())
	else:
		_switch_scene(new_scene)

func _spawn_sprite() -> Sprite2D:
	var sprite = Sprite2D.new()
	add_child(sprite)
	sprite.texture = _ballons.pick_random()
	sprite.position = _spawn_position
	return sprite

func _switch_scene(scene: Scene) -> void:
	get_tree().change_scene_to_packed(_scenes[scene])
