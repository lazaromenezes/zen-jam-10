extends Node2D

@export var _music_stream_player: AudioStreamPlayer
@export_range(0, 1) var _music_scale_factor: float = 0.1

var _increase_speed: float
var _pitch_scale: float

func _ready() -> void:
	_pitch_scale = _music_stream_player.pitch_scale
	_increase_speed = _music_scale_factor / 3

func _on_line_manager_delay_updated() -> void:
	_pitch_scale *= 1 + _music_scale_factor

func _process(delta: float) -> void:
	if _pitch_scale > _music_stream_player.pitch_scale:
		_music_stream_player.pitch_scale += _increase_speed * delta
