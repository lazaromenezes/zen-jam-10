class_name Kid
extends CharacterBody2D

const WALK_ANIM = &"walk"
const IDLE_ANIM = &"idle"
const HOLD_ANIM = &"hold"
const JUMP_ANIM = &"jump"
const FALL_ANIM = &"fall"

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
@export var _bounce_speed: float = -1000
@export var _visible_on_screen_notifier: VisibleOnScreenNotifier2D

var _dir: int = -1
var _state: State = State.INLINE
var _balloon: Balloon

func _ready() -> void:
	_change_dir(-1)

func _process(_delta: float) -> void:
	match _state:
		State.INLINE:
			if absf(velocity.x) > 0:
				_anim_sprite.play(WALK_ANIM)
			else:
				_anim_sprite.play(IDLE_ANIM)
		State.BOUNCING:
			if velocity.y > 0:
				_anim_sprite.play(FALL_ANIM)
			else:
				_anim_sprite.play(JUMP_ANIM)

func _physics_process(delta: float) -> void:
	match _state:
		State.INLINE:
			_handle_move(delta)
			_handle_gravity(delta)
			move_and_slide()
		State.BOUNCING:
			_handle_gravity(delta)
			move_and_slide()

func hold_balloon(balloon: Balloon) -> void:
	_balloon = balloon
	_anim_sprite.play(HOLD_ANIM)
	balloon.global_position = _hold_position.global_position
	reparent(balloon)
	_state = State.HOLDING

func _release_balloon() -> void:
	_balloon.detach_kid()
	_balloon = null
	reparent.call_deferred(get_tree().root)

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
		_anim_sprite.scale.x = dir

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is Stall:
		_change_dir(0)
		var stall := area.owner as Stall
		stall.create_balloon.call_deferred()
		stall.set_next_inline(self)
	elif area.owner is Trampoline and _state == State.HOLDING:
		_state = State.BOUNCING
		_release_balloon()
		velocity.y = _bounce_speed
		var trampoline = area.owner as Trampoline
		trampoline.push()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _state == State.HOLDING:
		if _balloon and _balloon.get_v_speed() > 0:
			_release_balloon()
			_state = State.INLINE
			_change_dir(-1)
	elif _state == State.BOUNCING:
		_state = State.INLINE
		_change_dir(1)
		_visible_on_screen_notifier.screen_exited.connect(queue_free)
