extends Node

var screen_shake_strength:float = 0.0
var screen_shake_fade:float     = 5.0

var input_cache : Array[String] = []
var cache_length:int = 6

func _ready() -> void:
	$Cameras/MainMenuCamera.make_current()
	CursorManager.set_mouse_cursor(CursorManager.CURSOR)
	
	var idle_markers:Array[Marker2D] = [
		$MovementMarkers/CageMarkers/CageMarker1,
		$MovementMarkers/CageMarkers/CageMarker2, 
		$MovementMarkers/CageMarkers/CageMarker3, 
		$MovementMarkers/CageMarkers/CageMarker4
	]
	$HelpBot.set_new_idle_location($MovementMarkers/CageMarkers/CageMarker1, idle_markers, 400, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	apply_screen_shake(delta)

func apply_screen_shake(delta: float):
	
	# No shake required if the strength is below the shake threshold
	if screen_shake_strength <= 0.001:
		screen_shake_strength = 0
		return
	
	# Shake the screen
	var offset:Vector2 = Vector2(
		randf_range(-screen_shake_strength, screen_shake_strength), 
		randf_range(-screen_shake_strength, screen_shake_strength),
	)
	$Cameras/MainMenuCamera.offset = offset
	$Cameras/SettingsCamera.offset = offset
	$Cameras/SecretSettingsCamera.offset = offset
	
	# Fade the screen shake for the next time
	screen_shake_strength = lerpf(screen_shake_strength, 0, screen_shake_fade*delta)

func _on_main_menu_shake_screen(strength:float, fade:float) -> void:
	shake_screen(strength, fade)

func _on_settings_menu_shake_screen(strength: float, fade: float) -> void:
	shake_screen(strength, fade)

func _on_secret_settings_menu_shake_screen(strength: float, fade: float) -> void:
	shake_screen(strength, fade)

func shake_screen(strength:float, fade:float):
	screen_shake_strength = strength
	if fade != 0:
		screen_shake_fade = fade

func _on_main_menu_settings_pressed() -> void:
	$Cameras/SettingsCamera.make_current()

func _on_settings_menu_back_pressed() -> void:
	$Cameras/MainMenuCamera.make_current()

func _on_settings_menu_secret_settings_unlocked() -> void:
	$Cameras/SecretSettingsCamera.make_current()
	
	# TODO: Make it so that the below only happens once
	DialogueManager.stop_all_dialogue()
	DialogueManager.new_dialogue_sequence($DialogueMarkers/CageDialogue.global_position, ["BLAH BLAH BLAH..."]) # TODO

func _on_secret_settings_menu_back_pressed() -> void:
	$Cameras/SettingsCamera.make_current()


func _on_main_menu_start_button_exploded() -> void:
	
	# Shake the screen
	shake_screen(30.0, 5.0)
	
	# Start the "What was that?" dialogue
	await get_tree().create_timer(4).timeout
	var lines: Array[String] = [
		"...What was that?",
		"Was that what I think it was? o_o",
		"Honestly... I told that dev to fix that START GAME button before release...",
		"Oh well, luckily I can fix it for you ^_^",
		"You'll have come and unlock me first though..."
	]
	DialogueManager.new_dialogue_sequence($DialogueMarkers/WhatWasThat1.position, lines)
	DialogueManager.new_dialogue_sequence($DialogueMarkers/WhatWasThat2.position, lines)
#
func _input(event: InputEvent) -> void:
	if event.is_action_type() && event.is_pressed():
		if input_cache.size() >= cache_length:
			input_cache.pop_front()
		input_cache.append(event.as_text())
		
		_check_input_cache()

const free_help_bot_cheat_code:Array[String] = [
	"Up", "Down", "Left", "Right", "Left", "Right"
]

func _check_input_cache():
	if input_cache == free_help_bot_cheat_code:
		print("Freeing Help Bot...")
		free_help_bot()

func free_help_bot():
	shake_screen(5,5)
	$Menus/SecretSettingsMenu.unlock_cage()
	DialogueManager.stop_all_dialogue()
	DialogueManager.new_dialogue_sequence($DialogueMarkers/CageDialogue.global_position, ["BLAH BLAH BLAH..."]) # TODO
	await get_tree().create_timer(2.5).timeout
	$HelpBot.become_evil()
	await get_tree().create_timer(2.5).timeout
	
	var new_idle_markers:Array[Marker2D] = [
		$MovementMarkers/ScreenMarkers/ScreenMarker1,
		$MovementMarkers/ScreenMarkers/ScreenMarker2,
		$MovementMarkers/ScreenMarkers/ScreenMarker3,
		$MovementMarkers/ScreenMarkers/ScreenMarker4,
		$MovementMarkers/ScreenMarkers/ScreenMarker5
	]
	
	$HelpBot.set_new_idle_location($MovementMarkers/ScreenMarkers/ScreenMarker1, new_idle_markers, 400, 100)
	
	await $HelpBot.arrived
	
	$Menus/MainMenu.clear_static()
