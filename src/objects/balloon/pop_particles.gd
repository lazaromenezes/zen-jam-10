class_name PopParticles
extends GPUParticles2D

var shader_texture: Texture2D: 
	set(value):
		process_material.set_shader_parameter("sprite", value)

func _ready() -> void:
	emitting = true

func _on_finished() -> void:
	queue_free()
