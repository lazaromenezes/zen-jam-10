class_name StaticBalloon
extends TextureRect

@export_category("Popping Control")
@export var _particles_scene: PackedScene
@export var _min_pop_height: float = 750
@export var _max_pop_height: float = 100

@export_category("Balloon")
@export var _ballons: Array[Texture2D]

@export_category("Movement Control")
@export var _min_vertical_speed: float = 100
@export var _max_vertical_speed: float = 300
@export var _rotation_speed: float = 20
@export var _max_rotation: float = 30

@onready var _viewport_size: Vector2 = get_viewport_rect().size

var _vertical_speed: float
var _popping_height: float
var _shake_dir: int = 1

func _ready() -> void:
	hide()
	texture = _ballons.pick_random()
	_vertical_speed = randf_range(_min_vertical_speed, _max_vertical_speed)
	_popping_height = randf_range(_min_pop_height, _max_pop_height)
	global_position = Vector2(randf_range(50, _viewport_size.x), 1200)
	pivot_offset = size / 2
	show()

func _process(delta: float) -> void:
	global_position.y -= _vertical_speed * delta
	_in_flight_shake(delta)
	if global_position.y < _popping_height:
		_pop()
		
func _pop() -> void:
	var particles = _particles_scene.instantiate() as PopParticles
	add_sibling(particles)
	particles.shader_texture = texture
	particles.global_position = global_position
	queue_free()
	
func _in_flight_shake(delta: float) -> void:
	rotation += deg_to_rad(_shake_dir * _rotation_speed * delta)
	if rotation >= deg_to_rad(_max_rotation):
		_shake_dir = -1
	if rotation <= deg_to_rad(-_max_rotation):
		_shake_dir = 1
