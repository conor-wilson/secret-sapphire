extends Node2D

# TODO: Add a bunch of dialogue that explains what's going on...

signal back_pressed
signal toggle_free_roam_camera(toggled_on:bool)
signal toggle_camera_zoom(toggled_on:bool)
signal t_1_collected(global_pos:Vector2)

func _process(delta: float) -> void:
	if !$T1.can_collect:
		$T1.can_collect = check_t_1_collectable()

func check_t_1_collectable() -> bool:
	return $SpecialBreakableBlocks.get_used_cells().size() == 0

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


func _on_back_button_pressed() -> void:
	if !Global.sfx_muted: $Sound/SelectNoise.play()
	back_pressed.emit()

func unlock_free_roaming_camera() -> void:
	_detatch_element_if_exists("Locks/FreeRoamCameraLock", 20)
	$CenterContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/EnableFreeRoamCameraBox/EnableFreeRoamCamera.disabled = false
	$CenterContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/EnableFreeRoamCameraBox/EnableFreeRoamCamera.update_icon(true)

func unlock_camera_zoom() -> void:
	_detatch_element_if_exists("Locks/CameraZoomLock", 20)
	$CenterContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/EnableCameraZoomBox/EnableCameraZoom.disabled = false
	$CenterContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/EnableCameraZoomBox/EnableCameraZoom.update_icon(true)


func _on_enable_free_roam_camera_box_toggled(toggled_on: bool) -> void:
	toggle_free_roam_camera.emit(toggled_on)


func _on_enable_camera_zoom_box_toggled(toggled_on: bool) -> void:
	toggle_camera_zoom.emit(toggled_on)

func hide_letter():
	$T1.show()
	$SpecialBreakableBlocks.show()

func _on_t_1_collect() -> void:
	t_1_collected.emit($T1.global_position)
