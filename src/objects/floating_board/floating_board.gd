extends Control
class_name FloatingBanner

@export var _icons: Array[Texture2D]

func _ready() -> void:
	%LeftBaloon.texture = _icons.pick_random()
	%RightBaloon.texture = _icons.pick_random()
	for button in %Buttons.get_children():
		button.focus_entered.connect(_on_button_focus.bind(button))
		
func _get_configuration_warnings() -> PackedStringArray:
	return ["This node requires any Control as children"]

func select_first_option() -> void:
	%PlayAgain.grab_focus()
	%SelectionIndicator.show()

func _on_button_focus(button: Button) -> void:
	%SelectionIndicator.set_placement(button)
