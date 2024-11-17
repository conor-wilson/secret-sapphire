class_name BreakableElement extends Node2D

signal settings_pressed
signal shake_screen(strength:float, fade:float)
signal start_button_exploded

#func _process(delta: float) -> void:
	#_check_for_screws()

func _on_start_button_smash() -> void:
	for letter in $Letters.get_children(): 
		letter.spawn()
	start_button_exploded.emit()

func _on_start_button_click() -> void:
	$InteractiveElements/StartButton.detatch(10)
	shake_screen.emit(10, 5.0)

func _on_settings_button_pressed() -> void:
	settings_pressed.emit()

var panel_screw_count:int = 4

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
		# TODO: Consider adding an animation for unscrewing the screws
		screw.detatch(10)
		panel_screw_count -= 1
		_check_panel_detatchment()
	
func _check_panel_detatchment():
	if panel_screw_count == 0:
		_detatch_element_if_exists("InteractiveElements/Panel", 1)
		_detatch_element_if_exists("InteractiveElements/StartButton", 10)
		$MarginContainer/VBoxContainer/Title.text = " "

func _detatch_element_if_exists(path: NodePath, strength:float=1):
	var element := get_node_or_null(path)
	
	# Check that the element can be detatched
	if element == null: return
	if !element.idle:   return
	
	# Detatch element
	element.detatch(strength)


func _on_panel_smash() -> void:
	shake_screen.emit(25,5)
