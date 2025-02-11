class_name Stall
extends Node2D

signal balloon_popped()

@export var _balloon_scene: PackedScene

var _next_inline: Kid

func create_balloon() -> void:
	var balloon := _balloon_scene.instantiate() as Balloon
	add_child(balloon)
	balloon.set_stall(self)
	balloon.global_position = global_position
	balloon.pop.connect(_on_balloon_popped)

func set_next_inline(next_kid: Kid) -> void:
	_next_inline = next_kid

func get_next_inline() -> Kid:
	return _next_inline

func _on_balloon_popped() -> void:
	balloon_popped.emit()
	await get_tree().create_timer(1).timeout
	create_balloon.call_deferred()
