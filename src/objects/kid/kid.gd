class_name Kid
extends CharacterBody2D

const WALK_ANIM = &"walk"
const IDLE_ANIM = &"idle"
const HOLD_ANIM = &"hold"

enum State {
	INLINE,
	HOLDING,
	BOUNCING,
	EXITING
}

@export var _anim_sprite: AnimatedSprite2D
@export var _speed: float = 5000
@export var _gravity: float = 900
@export var _hold_position: Marker2D

var _dir: int = -1
var _state: State = State.INLINE

func _ready() -> void:
	_change_dir(-1)

func _process(_delta: float) -> void:
	match _state:
		State.INLINE:
			if absf(velocity.x) > 0:
				_anim_sprite.play(WALK_ANIM)
			else:
				_anim_sprite.play(IDLE_ANIM)

func _physics_process(delta: float) -> void:
	match _state:
		State.INLINE:
			_handle_move(delta)
			_handle_gravity(delta)
			move_and_slide()

func hold_balloon(balloon: Balloon) -> void:
	_state = State.HOLDING
	_anim_sprite.play(HOLD_ANIM)
	balloon.global_position = _hold_position.global_position
	reparent(balloon)

func _handle_move(delta: float) -> void:
	if not is_on_floor():
		return
	if _dir != 0:
		velocity.x = _dir * _speed * delta
	else:
		velocity.x = 0

func _handle_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0
		return
	velocity.y += _gravity * delta

func _change_dir(dir: int) -> void:
	_dir = dir
	if absi(dir) > 0:
		scale.x = dir

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is Stall:
		_change_dir(0)
		var stall := area.owner as Stall
		stall.create_balloon.call_deferred()
		stall.set_next_inline(self)
