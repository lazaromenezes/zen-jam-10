extends Control

@export var _baloons_per_spawn: int = 5
@export var _min_wait_time: float = 0.6
@export var _max_wait_time: float = 1.5

@export var _baloon_scene: PackedScene

func _ready() -> void:
	_start_timer()
	
func _start_timer() -> void:
	$Timer.start(randf_range(_min_wait_time, _max_wait_time))
	
func _on_timer_timeout() -> void:
	var total := randi_range(1, _baloons_per_spawn)
	
	for spawning_baloon in total:
		var balloon = _baloon_scene.instantiate()
		add_child(balloon)
		
	_start_timer()
	
