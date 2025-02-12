class_name Balloon
extends Node2D

signal pop
signal released
signal start_inflating
signal stop_inflating

@export_category("Balloon")
@export var _ballons: Array[Texture2D]
@export var _sprite: Sprite2D
@export var _sprite_pivot: Node2D

@export_category("Baloon Sizing")
@export var _max_size: float = 100
@export var _min_scale: float = 0.5
@export var _max_scale: float = 1.5

@export_category("Inflate Control")
@export var _inflating_speed: float = 30
@export var _inflating_speed_offset: float = 10
@export var _deflate_rate: float = 0.5

@export_category("Movement Settings")
@export var _h_speed: float = 320
@export var _max_shake_rotation_deg: float = 45
@export var _shake_speed: float = 10
@export var _max_in_flight_rotation_deg: float = 10
@export var _in_flight_shake_speed: float = 0.2

@export_category("Particles")
@export var _particles_scene: PackedScene

@export_category("Other")
@export var _points_scene: PackedScene
@export var _gravity: float = 200
@export var _visible_on_screen_notifier: VisibleOnScreenNotifier2D

@export_category("SFX Control")
@export var _min_pitch_scale: float = 1
# The UI allows only up to 4, but it seems to make a difference...
@export var _max_pitch_scale: float = 50 
@export var _min_volume_db: float = -24
@export var _max_volume_db: float = -12


var _inflating: bool = false
var _size: float = 0
var _released: bool = false
var _v_speed: float
var _stall: Stall
var _shake_dir: int = 1


var _size_max_ratio: float:
	get: return _size / _max_size

func _ready() -> void:
	_sprite.texture = _ballons.pick_random()
	_sprite.scale = Vector2(_min_scale, _min_scale)
	_inflating_speed = randf_range(_inflating_speed - _inflating_speed_offset, _inflating_speed + _inflating_speed_offset)

func _process(delta: float) -> void:
	if not _released and Input.is_action_just_pressed("ui_accept"):
		_inflating = true
		start_inflating.emit()
	if not _released and _inflating and Input.is_action_just_released("ui_accept"):
		_stop_inflating()
		_release_ballon()
	
	if _inflating:
		_inflate(delta)
	if _released:
		_move(delta)
		_deflate(delta)
		_update_scale()

func set_stall(stall: Stall) -> void:
	_stall = stall

func detach_kid() -> void:
	_v_speed = -500
	_h_speed = 0
	_gravity = 0
	_visible_on_screen_notifier.screen_exited.connect(queue_free)

func get_v_speed() -> float:
	return _v_speed

func _move(delta: float) -> void:
	_v_speed += _gravity * delta
	global_position += Vector2(_h_speed, _v_speed) * delta
	_in_flight_shake(delta)

func _inflate(delta: float) -> void:
	_size += _inflating_speed * delta
	if _size > _max_size:
		_pop()
		stop_inflating.emit()
	else:
		_play_wind_sound()
		_update_scale()
		_scale_inflate_sound()
		_shake(delta)

func _deflate(delta: float) -> void:
	_size -= _inflating_speed * _deflate_rate * delta
	_size = maxf(0, _size)
	_play_wind_sound()
	_scale_deflate_sound()

func _scale_inflate_sound() -> void:
	%WindNoise.pitch_scale = lerp(_min_pitch_scale, _max_pitch_scale, _size_max_ratio)
	%WindNoise.volume_db = lerp(_min_volume_db, _max_volume_db, _size_max_ratio)

func _scale_deflate_sound() -> void:
	%WindNoise.pitch_scale = _min_pitch_scale + (_max_pitch_scale - _min_pitch_scale) * _size_max_ratio
	%WindNoise.volume_db = _max_volume_db * (1 + _size_max_ratio)

func _play_wind_sound() -> void:
	if not %WindNoise.playing:
		%WindNoise.play()

func _shake(delta: float) -> void:
	_sprite_pivot.rotate(_shake_dir * _shake_speed * delta)
	var amplitude := inverse_lerp(_max_size, 0, _size) * _max_shake_rotation_deg
	if _sprite_pivot.rotation >= deg_to_rad(amplitude):
		_shake_dir = -1
	if _sprite_pivot.rotation <= deg_to_rad(-amplitude):
		_shake_dir = 1
		
func _in_flight_shake(delta: float) -> void:
	_sprite_pivot.rotate(_shake_dir * _in_flight_shake_speed * delta)
	if _sprite_pivot.rotation >= deg_to_rad(_max_in_flight_rotation_deg):
		_shake_dir = -1
	if _sprite_pivot.rotation <= deg_to_rad(-_max_in_flight_rotation_deg):
		_shake_dir = 1

func _update_scale() -> void:
	var sprite_scale := lerpf(_min_scale, _max_scale, _size/_max_size)
	_sprite.scale = Vector2(sprite_scale, sprite_scale)

func _update_color() -> void:
	var value = lerp(1, 0, _size/_max_size)
	_sprite.self_modulate = Color(0.5, value, value)

func _stop_inflating() -> void:
	_inflating = false
	stop_inflating.emit()
	%WindNoise.playing = false

func _release_ballon() -> void:
	_attach_kid()
	%ReleaseNoise.play(0.25)
	
	_released = true
	_v_speed = -_size * 5
	_sprite.self_modulate = Color.WHITE
	_sprite_pivot.rotation = 0
	_spawn_points(int(_size_max_ratio * 100))
	released.emit()

func _attach_kid() -> void:
	var kid := _stall.get_next_inline()
	kid.hold_balloon(self)

func _pop() -> void:
	pop.emit()
	_spawn_particles()
	queue_free()

func _spawn_points(value: int) -> void:
	var points := _points_scene.instantiate() as Control
	add_sibling(points)
	points.global_position = global_position
	points.get_node("Label").text = str(value)

func _spawn_particles() -> void:
	var particles := _particles_scene.instantiate() as PopParticles
	particles.shader_texture = _sprite.texture
	add_sibling(particles)
	particles.global_position = global_position
