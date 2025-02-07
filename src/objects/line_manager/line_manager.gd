class_name LineManager
extends Node2D

@export var _kid_scene: PackedScene
@export var _initial_delay: float = 8
@export var _timer: Timer

var _current_delay: float

func _ready() -> void:
	_spawn_kid.call_deferred()
	_current_delay = _initial_delay
	_timer.start(_current_delay)
	_timer.timeout.connect(_on_timeout)

func _spawn_kid() -> void:
	var kid := _kid_scene.instantiate() as Kid
	add_sibling(kid)
	kid.global_position = global_position

func _on_timeout() -> void:
	_spawn_kid()
