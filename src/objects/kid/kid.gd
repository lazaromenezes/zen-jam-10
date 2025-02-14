class_name Kid
extends CharacterBody2D

signal bouncing
signal enter_line
signal exit_line

const WALK_ANIM = &"walk"
const IDLE_ANIM = &"idle"
const HOLD_ANIM = &"hold"
const JUMP_ANIM = &"jump"
const FALL_ANIM = &"fall"
const SCARED_ANIM = &"scared"
const HOLD_START_OFFSET = Vector2(0, -10)

enum State {
	INLINE,
	HOLDING,
	BOUNCING,
	EXITING,
	SCARED
}

@export var _available_animations: Array[SpriteFrames]

@export var _anim_sprite: AnimatedSprite2D
@export var _speed: float = 5000
@export var _gravity: float = 900
@export var _hold_position: Marker2D
@export var _bounce_speed: float = -1000
@export var _visible_on_screen_notifier: VisibleOnScreenNotifier2D
@export var _raycast: RayCast2D
@export var _area: Area2D

var _dir: int = -1
var _state: State = State.INLINE
var _balloon: Balloon
var _is_next_inline: bool = false
var _just_landed: bool = false
var _inline: bool = false

func _ready() -> void:
	_anim_sprite.sprite_frames = _available_animations.pick_random()
	_raycast.add_exception(_area)
	_change_dir(-1)

func _process(_delta: float) -> void:
	match _state:
		State.INLINE:
			_update_move_animation()
		State.BOUNCING:
			_update_jump_animation()
		State.EXITING:
			_update_move_animation()
		State.SCARED:
			_anim_sprite.play(SCARED_ANIM)

func _physics_process(delta: float) -> void:
	match _state:
		State.INLINE:
			if _is_waiting_spot():
				return
			else:
				_enter_spot()
			_check_near_kid()
			_handle_move(delta)
			_handle_gravity(delta)
			move_and_slide()
		State.BOUNCING:
			_handle_gravity(delta)
			move_and_slide()
		State.EXITING:
			_handle_move(delta)
			_handle_gravity(delta)
			move_and_slide()

func hold_balloon(balloon: Balloon) -> void:
	_balloon = balloon
	_anim_sprite.play(HOLD_ANIM)
	global_position += HOLD_START_OFFSET
	balloon.global_position = _hold_position.global_position
	reparent(balloon)
	_state = State.HOLDING
	_is_next_inline = false
	_inline = false
	exit_line.emit()

func get_state() -> State:
	return _state

func _enter_spot() -> void:
	if _just_landed:
		_just_landed = false
		_change_dir(-1)

func _is_waiting_spot() -> bool:
	if _just_landed and _raycast.is_colliding():
		var collider := _raycast.get_collider()
		if collider:
			var kid := collider.owner as Kid
			if kid and kid.global_position.x < global_position.x:
				return true
	return false

func _update_move_animation() -> void:
	if absf(velocity.x) > 0:
		_anim_sprite.play(WALK_ANIM)
	else:
		_anim_sprite.play(IDLE_ANIM)

func _update_jump_animation() -> void:
	if velocity.y > 0:
		_anim_sprite.play(FALL_ANIM)
	else:
		_anim_sprite.play(JUMP_ANIM)

func _check_near_kid() -> void:
	if _is_next_inline:
		return
	if _raycast.is_colliding():
		var collider := _raycast.get_collider()
		if collider:
			var kid := collider.owner as Kid
			if kid and kid.global_position.x < global_position.x:
				_change_dir(0)
				if not _inline and kid.get_state() == State.INLINE:
					_inline = true
					enter_line.emit()
			else:
				_change_dir(-1)
	else:
		_change_dir(-1)

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
		stall.balloon_popped.connect(_on_balloon_popped)
		stall.set_next_inline(self)
		_is_next_inline = true
		if not _inline:
			_inline = true
			enter_line.emit()
	elif area.owner is Trampoline and _state == State.HOLDING:
		_state = State.BOUNCING
		_release_balloon()
		velocity.y = _bounce_speed
		var trampoline = area.owner as Trampoline
		trampoline.push()
		bouncing.emit()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _state == State.HOLDING:
		if _balloon and _balloon.get_v_speed() > 0:
			_release_balloon()
			_just_landed = true
			_state = State.INLINE
	elif _state == State.BOUNCING:
		_state = State.EXITING
		_change_dir(1)
		_visible_on_screen_notifier.screen_exited.connect(queue_free)

func _on_balloon_popped():
	if _state == State.INLINE:
		_state = State.SCARED

func _on_animated_sprite_2d_animation_finished() -> void:
	if _anim_sprite.animation == SCARED_ANIM:
		_state = State.INLINE

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner is Stall:
		var stall := area.owner as Stall
		stall.balloon_popped.disconnect(_on_balloon_popped)
