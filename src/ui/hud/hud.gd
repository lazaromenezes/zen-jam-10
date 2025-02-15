class_name HUD
extends MarginContainer

@export var _in_line_label: Label
@export var _score_label: Label
@export var _timer_label: Label
@export var _line_manager: LineManager

@onready var _start_time := Time.get_ticks_msec()

@export var _session: GameSession

func _ready() -> void:
	_line_manager.updated_line.connect(_on_update_in_line_count)
	_line_manager.scored.connect(_on_update_score)
	_on_update_in_line_count(0)

func _process(_delta: float) -> void:
	var time := (Time.get_ticks_msec() - _start_time)/1000.0
	_timer_label.text = "Timer: %.1f" % [time]
	_session.time = time

func _on_update_in_line_count(count: int) -> void:
	_in_line_label.text = "Kids in line: " + str(count) + "/" + str(_line_manager.get_max_kids_inline())

func _on_update_score(score: int) -> void:
	_score_label.text = "Score: " + str(score)
	_session.score = score
