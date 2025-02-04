class_name Balloon
extends Node2D

signal pop
signal released

@export var _max_size: float = 100
@export var _inflating_speed: float = 50
@export var _sprite: Sprite2D
@export var _min_scale: float = 0.5
@export var _max_scale: float = 1
@export var _h_speed: float = 320
@export var _gravity: float = 200
@export var _points_scene: PackedScene
@export var _ballons: Array[Texture2D]
@export var _sprite_pivot: Node2D
@export var _max_shake_rotation_deg: float = 45
@export var _shake_speed: float = 10

var _inflating: bool = false
var _size: float = 0
var _released: bool = false
var _v_speed: float
var _stall: Stall
var _shake_dir: int = 1

func _ready() -> void:
	_sprite.texture = _ballons.pick_random()
	_sprite.scale = Vector2(_min_scale, _min_scale)

func _process(delta: float) -> void:
	if not _released and Input.is_action_just_pressed("ui_accept"):
		_inflating = true
	if not _released and _inflating and Input.is_action_just_released("ui_accept"):
		_stop_inflating()
	
	if _inflating:
		_inflate(delta)
	if _released:
		_move(delta)
		_size -= _inflating_speed * 0.5 * delta
		_size = maxf(0, _size)
		_update_scale()

func set_stall(stall: Stall) -> void:
	_stall = stall

func _move(delta: float) -> void:
	_v_speed += _gravity * delta
	global_position += Vector2(_h_speed, _v_speed) * delta

func _inflate(delta: float) -> void:
	_size += _inflating_speed * delta
	if _size > _max_size:
		_pop()
	else:
		_update_scale()
		_shake(delta)

func _shake(delta: float) -> void:
	_sprite_pivot.rotate(_shake_dir * _shake_speed * delta)
	var amplitude := inverse_lerp(_max_size, 0, _size) * _max_shake_rotation_deg
	if _sprite_pivot.rotation >= deg_to_rad(amplitude):
		_shake_dir = -1
	if _sprite_pivot.rotation <= deg_to_rad(-amplitude):
		_shake_dir = 1

func _update_scale() -> void:
	var sprite_scale := lerpf(_min_scale, _max_scale, _size/_max_size)
	_sprite.scale = Vector2(sprite_scale, sprite_scale)

func _update_color() -> void:
	var value = lerp(1, 0, _size/_max_size)
	_sprite.self_modulate = Color(0.5, value, value)

func _stop_inflating() -> void:
	_inflating = false
	_release_ballon()

func _release_ballon() -> void:
	_released = true
	_v_speed = -_size * 5
	_sprite.self_modulate = Color.WHITE
	_sprite_pivot.rotation = 0
	_spawn_points(int((_size/_max_size) * 100))
	released.emit()

func _pop() -> void:
	print("Pop")
	_sprite.visible = false
	pop.emit()
	queue_free()

func _spawn_points(value: int) -> void:
	var points := _points_scene.instantiate() as Control
	add_sibling(points)
	points.global_position = global_position
	points.get_node("Label").text = str(value)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	_spawn_points(int(global_position.distance_to(_stall.global_position)))
	queue_free()
