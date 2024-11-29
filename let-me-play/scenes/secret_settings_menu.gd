extends Node2D

# TODO: Add a bunch of dialogue that explains what's going on...

signal shake_screen(strength:float, fade:float)
signal back_pressed
signal toggle_free_roam_camera(toggled_on:bool)

func unlock_cage():
	_detatch_element_if_exists("Cage", 1)

# TODO: This is a duplicate of the same function in main_menu.gd. Deduplicate
# this.
func _detatch_element_if_exists(path: NodePath, strength:float=1):
	var element := get_node_or_null(path)
	
	# Check that the element can be detatched
	if element == null: return
	if element is not InteractiveElement: return
	if !element.idle:   return
	
	# Detatch element
	element.detatch(strength)


func _on_cage_smash() -> void:
	shake_screen.emit(10,5)


func _on_back_button_pressed() -> void:
	back_pressed.emit()

func unlock_free_roaming_camera() -> void:
	_detatch_element_if_exists("Locks/FreeRoamCameraLock", 20)
	$CenterContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/EnableFreeRoamCamera.disabled = false
	$CenterContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/EnableFreeRoamCamera.update_icon(true)

func _on_free_roam_camera_lock_smash() -> void:
	shake_screen.emit(10,5)


func _on_enable_free_roam_camera_box_toggled(toggled_on: bool) -> void:
	toggle_free_roam_camera.emit(toggled_on)
