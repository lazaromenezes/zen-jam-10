extends Control

func _ready() -> void:
	for option: Button in %MenuContainer.get_children():
		option.focus_entered.connect(_menu_option_focus_entered.bind(option))
	
	_select_first_option.call_deferred()
	

func _menu_option_focus_entered(target: Button) -> void:
	%SelectionIndicator.set_placement(target)
	
func _select_first_option() -> void:
	%SinglePlayer.grab_focus()
	%SelectionIndicator.show()
