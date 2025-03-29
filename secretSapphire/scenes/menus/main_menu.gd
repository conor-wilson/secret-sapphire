extends Node2D

signal settings_pressed
signal start_button_exploded
signal panel_broken
signal s_collected(global_pos:Vector2)
signal a_collected(global_pos:Vector2)
signal hammer_man_level_changed

var panel_screw_count:int = 4

# TODO: Organise this code file. It's a damn mess.

func _on_start_button_smash() -> void:
	$RigidLetters.show()
	for letter in $RigidLetters.get_children():
		letter.detatch()
		letter.apply_random_force()
	start_button_exploded.emit()

func _on_start_button_click() -> void:
	$InteractiveElements/StartButton.detatch(10)

func _on_settings_button_pressed() -> void:
	if !Global.sfx_muted: $Sound/SelectNoise.play()
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
		# TODO: Consider adding an animation for unscrewing the screws
		if screw.gravity_scale != 0:
			return
		screw.detatch(10)
		panel_screw_count -= 1
		_check_panel_detatchment()
	
func _check_panel_detatchment():
	if panel_screw_count == 0:
		_detatch_element_if_exists("InteractiveElements/Panel", 1)
		_detatch_element_if_exists("InteractiveElements/StartButton", 10)
		$Desktop.set_static_mode()
		$MarginContainer/VBoxContainer/Title.text = " " # TODO: Attach the text to the panel

func _detatch_element_if_exists(path: NodePath, strength:float=1):
	var element := get_node_or_null(path)
	
	# Check that the element can be detatched
	if element == null: return
	if element is not InteractiveElement: return
	if !element.idle:   return
	
	# Detatch element
	element.detatch(strength)


func _on_panel_smash() -> void:
	panel_broken.emit()

func clear_static():
	_detatch_element_if_exists("InteractiveElements/Screw1")
	_detatch_element_if_exists("InteractiveElements/Screw2")
	_detatch_element_if_exists("InteractiveElements/Screw3")
	_detatch_element_if_exists("InteractiveElements/Screw4")
	panel_screw_count = 0
	_check_panel_detatchment()
	$Desktop.clear_all_static()

func detatch_sticky_note():
	$InteractiveElements/StickyNote.hide()
	$InteractiveElements/CrumpledStickyNote.show()
	
	$InteractiveElements/CrumpledStickyNote.gravity_scale = 1
	var x_force:float = randf_range(-750, 750)
	var y_force:float = randf_range(-750, 0)
	$InteractiveElements/CrumpledStickyNote.apply_impulse(Vector2(x_force,y_force), Vector2(10,10))

#
## TODO: This is purely for debugging. This function should be removed once it's
## no-longer needed.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debugbutton"):
		#animate_letters()

func animate_letters():
	$RunningLetters/S.spawn($RigidLetters/S.position+Vector2(0,-35))
	$RunningLetters/T1.spawn($RigidLetters/T1.position+Vector2(0,-35))
	$RunningLetters/A1.spawn($RigidLetters/A1.position+Vector2(0,-35))
	$RunningLetters/R.spawn($RigidLetters/R.position+Vector2(0,-35))
	$RunningLetters/T2.spawn($RigidLetters/T2.position+Vector2(0,-35))
	
	$RigidLetters/S.queue_free()
	$RigidLetters/T1.queue_free()
	$RigidLetters/A1.queue_free()
	$RigidLetters/R.queue_free()
	$RigidLetters/T2.queue_free()

func get_letter_positions() -> Array[Vector2]:
	
	var output:Array[Vector2] = []
	for letter in $RigidLetters.get_children():
		output.append(letter.global_position)
	
	return output

func activate_desktop():
	$Desktop.set_active_mode()

func _on_desktop_a_collected(global_pos:Vector2) -> void:
	a_collected.emit(global_pos)

func _on_desktop_s_collected(global_pos:Vector2) -> void:
	s_collected.emit(global_pos)

func _on_crumpled_sticky_note_click() -> void:
	$InteractiveElements/CrumpledStickyNote.hide()
	CursorManager.set_mouse_cursor(CursorManager.CRUMPLED_PAPER)

func _on_desktop_hammer_man_level_changed() -> void:
	hammer_man_level_changed.emit()


func _on_start_button_mouse_entered() -> void:
	$InteractiveElements/StartButton.scale = Vector2(1.05,1.05)

func _on_start_button_mouse_exited() -> void:
	$InteractiveElements/StartButton.scale = Vector2(1,1)
