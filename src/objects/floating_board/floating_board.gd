extends Control
class_name FloatingBanner

@export var _icons: Array[Texture2D]

func _ready() -> void:
	%LeftBaloon.texture = _icons.pick_random()
	%RightBaloon.texture = _icons.pick_random()
	%Exit.visible = not OS.has_feature("web")
	for button in %Buttons.get_children():
		button.focus_entered.connect(_on_button_focus.bind(button))

func select_first_option() -> void:
	%PlayAgain.grab_focus()
	%SelectionIndicator.show()

func _on_button_focus(button: Button) -> void:
	%SelectionIndicator.set_placement(button)

func _on_play_again_pressed() -> void:
	SceneManager.transition_to(SceneManager.Scene.MAP)

func _on_title_pressed() -> void:
	SceneManager.transition_to(SceneManager.Scene.TITLE)

func _on_exit_pressed() -> void:
	get_tree().quit()
