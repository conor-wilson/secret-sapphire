extends Node2D

signal settings_button

signal shake_screen(strength:float, fade:float)

func _on_start_button_collision() -> void:
	shake_screen.emit(30.0, 5.0)
	for letter in $Letters.get_children(): 
		letter.spawn()

func _on_start_button_click() -> void:
	shake_screen.emit(10, 5.0)

func _on_settings_button_pressed() -> void:
	settings_button.emit()
