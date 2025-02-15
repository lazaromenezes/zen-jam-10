extends Node2D

@export var game_session: GameSession

func _ready() -> void:
	game_session.score = 0
	game_session.time = 0
