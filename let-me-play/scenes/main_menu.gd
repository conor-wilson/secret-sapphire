extends Node2D

signal settings_pressed
signal shake_screen(strength:float, fade:float)
signal start_button_exploded

func _on_start_button_smash() -> void:
	for letter in $Letters.get_children(): 
		letter.spawn()
	start_button_exploded.emit()

func _on_start_button_click() -> void:
	$StartButton.detatch()
	shake_screen.emit(10, 5.0)

func _on_settings_button_pressed() -> void:
	settings_pressed.emit()
