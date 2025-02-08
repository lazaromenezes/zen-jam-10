extends Control

func _ready() -> void:
	for option: Button in %MenuContainer.get_children():
		option.focus_entered.connect(_menu_option_focus_entered.bind(option))
	
	%Exit.visible = not OS.has_feature("web")
	
	_select_first_option.call_deferred()

func _menu_option_focus_entered(target: Button) -> void:
	%SelectionIndicator.set_placement(target)
	
func _select_first_option() -> void:
	%SinglePlayer.grab_focus()
	%SelectionIndicator.show()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_single_player_pressed() -> void:
	SceneManager.transition_to(SceneManager.Scene.MAP)

func _on_options_pressed() -> void:
	pass # Replace with function body.
