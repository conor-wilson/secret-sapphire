extends Node2D

signal settings_button

signal shake_screen(strength:float, fade:float)

func _on_start_button_collision() -> void:
	shake_screen.emit(30.0, 5.0)
	for letter in $Letters.get_children(): 
		letter.spawn()
	
	# TODO: The below is just a proof of concept. Fix it into something more dynamic and reusable.
	await get_tree().create_timer(1.5).timeout
	var lines: Array[String] = [
		"What was that??",
		"Is everything ok out there?"
	]
	DialogueManager.start_dialogue($SettingsButton.global_position + Vector2(320, 40), lines)

func _on_start_button_click() -> void:
	shake_screen.emit(10, 5.0)

func _on_settings_button_pressed() -> void:
	settings_button.emit()
