class_name LineManager
extends Node2D

signal updated_line(count: int)
signal scored(score: int)

@export var _kid_scene: PackedScene
@export var _initial_delay: float = 8
@export var _kid_spawn_timer: Timer
@export var _speed_increase_timer: Timer
@export var _max_kids_inline: int = 7
@export_range(1, 100) var _time_increase_factor: int = 1
@export var _increase_speed_delay: float = 45
@export var _min_delay: float = 5
@export var _bounce_score: int = 100

var _current_delay: float
var _line_count: int
var _score: int
var _reset_timer: bool = false

func _ready() -> void:
	_spawn_kid.call_deferred()
	_current_delay = _initial_delay
	
	_kid_spawn_timer.start(_current_delay)
	_kid_spawn_timer.timeout.connect(_on_timeout)
	
	_speed_increase_timer.start(_increase_speed_delay)
	_speed_increase_timer.timeout.connect(_increase_speed)

func get_max_kids_inline() -> int:
	return _max_kids_inline

func _spawn_kid() -> void:
	var kid := _kid_scene.instantiate() as Kid
	add_sibling(kid)
	kid.global_position = global_position
	kid.enter_line.connect(_on_enter_line)
	kid.bouncing.connect(_on_bouncing)
	kid.exit_line.connect(_on_exit_line)

func _game_over() -> void:
	SceneManager.transition_to.call_deferred(SceneManager.Scene.GAME_OVER, false)

func _on_timeout() -> void:
	_spawn_kid()
	if _reset_timer:
		_kid_spawn_timer.start()
		_reset_timer = false

func _on_enter_line() -> void:
	_line_count += 1
	if _line_count > _max_kids_inline:
		_game_over()
	updated_line.emit(_line_count)

func _on_exit_line() -> void:
	_line_count -= 1
	updated_line.emit(_line_count)

func _on_bouncing() -> void:
	_score += _bounce_score
	scored.emit(_score)

func _increase_speed() -> void:
	_current_delay -= max(_min_delay, _current_delay * _time_increase_factor / 100)
	_reset_timer = true
