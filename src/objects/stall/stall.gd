class_name Stall
extends Node2D

signal balloon_popped()

@export var _balloon_scene: PackedScene
@export var _balloon_pos: Marker2D
@export var _anim_player: AnimationPlayer

var _next_inline: Kid

func create_balloon() -> void:
	var balloon := _balloon_scene.instantiate() as Balloon
	add_child(balloon)
	balloon.set_stall(self)
	balloon.global_position = _balloon_pos.global_position
	balloon.pop.connect(_on_balloon_popped)
	balloon.start_inflating.connect(_on_balloon_start_inflating)
	balloon.stop_inflating.connect(_on_balloon_stop_inflating)

func set_next_inline(next_kid: Kid) -> void:
	_next_inline = next_kid

func get_next_inline() -> Kid:
	return _next_inline

func _on_balloon_popped() -> void:
	balloon_popped.emit()
	await get_tree().create_timer(1).timeout
	create_balloon.call_deferred()

func _on_balloon_start_inflating() -> void:
	_anim_player.play(&"pump")

func _on_balloon_stop_inflating() -> void:
	_anim_player.stop()
