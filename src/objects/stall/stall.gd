class_name Stall
extends Node2D

@export var _balloon_scene: PackedScene

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	_create_balloon.call_deferred()

func _create_balloon() -> void:
	var balloon := _balloon_scene.instantiate() as Balloon
	add_child(balloon)
	balloon.set_stall(self)
	balloon.global_position = global_position
	balloon.released.connect(_on_balloon_released)
	balloon.pop.connect(_on_balloon_popped)

func _on_balloon_released() -> void:
	await get_tree().create_timer(1).timeout
	_create_balloon.call_deferred()

func _on_balloon_popped() -> void:
	await get_tree().create_timer(1).timeout
	_create_balloon.call_deferred()
