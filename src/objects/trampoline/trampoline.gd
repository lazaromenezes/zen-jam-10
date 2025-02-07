class_name Trampoline
extends Node2D

const PUSH_ANIM = &"push"

@export var _anim_sprite: AnimatedSprite2D

func push() -> void:
	_anim_sprite.play(PUSH_ANIM)
