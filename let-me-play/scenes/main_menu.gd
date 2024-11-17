extends Node2D

signal settings_pressed
signal shake_screen(strength:float, fade:float)
signal start_button_exploded

func _on_start_button_smash() -> void:
	for letter in $Letters.get_children(): 
		letter.spawn()
	start_button_exploded.emit()

func _on_start_button_click() -> void:
	$InteractiveElements/StartButton.detatch()
	shake_screen.emit(10, 5.0)

func _on_settings_button_pressed() -> void:
	settings_pressed.emit()

func _on_screw_1_click() -> void:
	_detatch_screw($InteractiveElements/Screw1)

func _on_screw_2_click() -> void:
	_detatch_screw($InteractiveElements/Screw2)

func _on_screw_3_click() -> void:
	_detatch_screw($InteractiveElements/Screw3)

func _on_screw_4_click() -> void:
	_detatch_screw($InteractiveElements/Screw4)

func _detatch_screw(screw:Node):
	if CursorManager.current_cursor_is(CursorManager.WRENCH):
		# TODO: Add some security checks in here
		screw.detatch()
	
