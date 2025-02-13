class_name LineManager
extends Node2D

signal updated_line(count: int)
signal scored(score: int)

@export var _kid_scene: PackedScene
@export var _initial_delay: float = 8
@export var _timer: Timer
@export var _max_kids_inline: int = 7
@export var _bounce_score: int = 100

var _current_delay: float
var _line_count: int
var _score: int

func _ready() -> void:
	_spawn_kid.call_deferred()
	_current_delay = _initial_delay
	_timer.start(_current_delay)
	_timer.timeout.connect(_on_timeout)

func get_max_kids_inline() -> int:
	return _max_kids_inline

func _spawn_kid() -> void:
	var kid := _kid_scene.instantiate() as Kid
	add_sibling(kid)
	kid.global_position = global_position
	kid.enter_line.connect(_on_enter_line)
	kid.bouncing.connect(_on_bouncing)

func _game_over() -> void:
	print("Game Over!!")

func _on_timeout() -> void:
	_spawn_kid()

func _on_enter_line() -> void:
	_line_count += 1
	if _line_count > _max_kids_inline:
		_game_over()
	updated_line.emit(_line_count)

func _on_bouncing() -> void:
	_line_count -= 1
	updated_line.emit(_line_count)
	_score += _bounce_score
	scored.emit(_score)
