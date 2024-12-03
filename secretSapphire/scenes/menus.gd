extends Node2D

signal start_game
signal mute_sfx_toggled
signal mute_music_toggled

var active:bool = true

var screen_shake_strength:float = 0.0
var screen_shake_fade:float     = 5.0

var input_cache : Array[String] = []
var cache_length:int = 8

var cursor_in_item_drop_zone:bool = false

@onready var wrench: InteractiveElement = $Items/Wrench
@onready var fire_extinguisher: InteractiveElement = $Items/FireExtinguisher
@onready var crumpled_password_hint: InteractiveElement = $Items/CrumpledPasswordHint
@onready var hammer_man: HammerMan = $HammerMan

# Stage indicates where we are in the game's story so that we can keep track of 
# dialogue
enum Stage {
	BEGINNING, 
	START_BUTTON_BROKEN, 
	SECRET_SETTINGS_UNLOCKED,
	HELP_BOT_FREED,
	HELP_BOT_WAITING_TO_MONOLOGUE,
	HELP_BOT_MONOLOGUING,
	LETTERS_MISSING,
	ALL_LETTERS_COLLECTED,
	READY_FOR_BOSS_BATTLE,
	BOSS_BATTLE,
	HELP_BOT_DYING,
	READY_TO_START_GAME
}
var stage:Stage = Stage.BEGINNING

func _ready() -> void:
	
	if !active: return
	
	fire_extinguisher.hide()
	crumpled_password_hint.hide()
	hammer_man.hide()
	hammer_man.active = false
	
	stage = Stage.BEGINNING
	
	$Camera/FreeRoamCamera.position = $Camera/MainMenuCameraMarker.position
	$Camera/FreeRoamCamera.make_current()
	CursorManager.set_mouse_cursor(CursorManager.CURSOR)
	
	var idle_markers:Array[Marker2D] = [
		$MovementMarkers/CageMarkers/CageMarker1,
		$MovementMarkers/CageMarkers/CageMarker2, 
		$MovementMarkers/CageMarkers/CageMarker3, 
		$MovementMarkers/CageMarkers/CageMarker4
	]
	$HelpBot.set_new_idle_location($MovementMarkers/CageMarkers/CageMarker1, idle_markers, 400, 10)

func play():
	show()
	active = true
	$Sound/DetectiveMusic.play()

func stop():
	hide()
	active = false
	$Sound/DetectiveMusic.stop()
	$Sound/MainMusic.stop()
	$Sound/BossBattleMusic.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !active: return
	
	apply_screen_shake(delta)

func apply_screen_shake(delta: float):
	
	if !active: return
	
	# No shake required if the strength is below the shake threshold
	if screen_shake_strength <= 0.001:
		screen_shake_strength = 0
		return
	
	# Shake the screen
	var offset:Vector2 = Vector2(
		randf_range(-screen_shake_strength, screen_shake_strength), 
		randf_range(-screen_shake_strength, screen_shake_strength),
	)
	$Camera/FreeRoamCamera.offset = offset
	
	# Fade the screen shake for the next time
	screen_shake_strength = lerpf(screen_shake_strength, 0, screen_shake_fade*delta)

func _on_main_menu_shake_screen(strength:float, fade:float) -> void:
	if !active: return
	if stage != Stage.HELP_BOT_MONOLOGUING:
		shake_screen(strength, fade)

func _on_settings_menu_shake_screen(strength: float, fade: float) -> void:
	if !active: return
	shake_screen(strength, fade)

func _on_secret_settings_menu_shake_screen(strength: float, fade: float) -> void:
	if !active: return
	shake_screen(strength, fade)

func shake_screen(strength:float, fade:float):
	if !active: return
	if !Global.sfx_muted: $Camera/FreeRoamCamera/VibrationNoise.play()
	screen_shake_strength = strength
	if fade != 0:
		screen_shake_fade = fade

func _on_main_menu_settings_pressed() -> void:
	if !active: return
	$Camera/FreeRoamCamera.position = $Camera/SettingsCameraMarker.position
	await $ItemDropZones/MainMenu.mouse_exited
	cursor_in_item_drop_zone = true

func _on_settings_menu_back_pressed() -> void:
	if !active: return
	$Camera/FreeRoamCamera.position = $Camera/MainMenuCameraMarker.position
	await $ItemDropZones/SettingsMenu.mouse_exited
	cursor_in_item_drop_zone = true
	
	if stage == Stage.HELP_BOT_WAITING_TO_MONOLOGUE:
		_begin_help_bot_monologue()
	elif stage == Stage.ALL_LETTERS_COLLECTED:
		reform_start_button() 

func _on_secret_settings_menu_back_pressed() -> void:
	if !active: return
	$Camera/FreeRoamCamera.position = $Camera/SettingsCameraMarker.position
	await $ItemDropZones/SecretSettingsMenu.mouse_exited
	cursor_in_item_drop_zone = true


func _on_main_menu_start_button_exploded() -> void:
	if !active: return
	
	$Sound/DetectiveMusic.stop()
	
	if stage != Stage.HELP_BOT_MONOLOGUING:
		if stage == Stage.BEGINNING && !Global.sfx_muted: $Sound/StaticNoise.volume_db = -10
		$Sound/StaticNoise.play()
	
	# Shake the screen
	shake_screen(30.0, 5.0)
	
	if stage == Stage.BEGINNING:
		stage = Stage.START_BUTTON_BROKEN
	
		# Start the "What was that?" dialogue
		await get_tree().create_timer(4).timeout
		_start_what_was_that_sequence()
		
func _start_what_was_that_sequence():
	if !active: return
	if stage == Stage.START_BUTTON_BROKEN:
		var lines: Array[String] = [
			"...What was that?",
			"Was that what I think it was? o_o",
			"I told that DEV to fix the START button... ¬_¬",
			"Oh well, luckily I can fix it for you ^_^",
			"You'll have to come and unlock me first though..."
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/SettingsButtonMarker.position, lines, "blue", 2, $DialogueMarkers/SettingsButtonMarker)
		if $Menus/SettingsMenu.secret_settings_locked: 
			DialogueManager.new_dialogue_sequence($DialogueMarkers/LockedSecretSettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/LockedSecretSettingsButtonMarker)
		else:
			DialogueManager.new_dialogue_sequence($DialogueMarkers/SecretSettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/SecretSettingsButtonMarker)


func _input(event: InputEvent) -> void:
	if !active: return
	
	if event.is_action("right_click"):
		_drop_held_item()
		
	if event.is_action_type() && event.is_pressed():
		if input_cache.size() >= cache_length:
			input_cache.pop_front()
		input_cache.append(event.as_text())
		
		_check_input_cache()
	
	if event.is_action("click") && CursorManager.current_cursor == CursorManager.FIRE_EXTINGUISHER:
		$Foam.start_following()
	if event.is_action_released("click"):
		$Foam.stop_following()

##
### TODO: This is purely for debugging. This function should be removed once it's
### no-longer needed.
##func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debugbutton"):
		#reform_start_button()

func reform_start_button():
	if !active: return
	await get_tree().create_timer(1).timeout
	
	$CollectedLetters.jump()
	
	await $CollectedLetters.jump_finished
	
	$TrueStartButton.show()
	shake_screen(20,5)
	$TrueStartButton.detatch(40)
	
	stage = Stage.READY_FOR_BOSS_BATTLE
	

func _drop_held_item():
	if !active: return
	
	if CursorManager.current_cursor != CursorManager.CURSOR && !cursor_in_item_drop_zone:
		print("cannot drop item")
		shake_screen(5,5)
		return
	
	match CursorManager.current_cursor:
		CursorManager.WRENCH:
			$ItemInstructions.hide()
			CursorManager.set_mouse_cursor(CursorManager.CURSOR)
			
			var new_wrench:InteractiveElement = wrench.duplicate()
			wrench.queue_free()
			
			add_child(new_wrench)
			new_wrench.show()
			new_wrench.position = get_local_mouse_position()
			new_wrench.detatch(20)
			wrench = new_wrench
		
		CursorManager.CRUMPLED_PAPER:
			$ItemInstructions.hide()
			CursorManager.set_mouse_cursor(CursorManager.CURSOR)
			
			var new_crumpled_password_hint:InteractiveElement = crumpled_password_hint.duplicate()
			crumpled_password_hint.queue_free()
			
			add_child(new_crumpled_password_hint)
			new_crumpled_password_hint.show()
			new_crumpled_password_hint.position = get_local_mouse_position()
			new_crumpled_password_hint.detatch(50)
			crumpled_password_hint = new_crumpled_password_hint
		
		CursorManager.FIRE_EXTINGUISHER:
			$ItemInstructions.hide()
			CursorManager.set_mouse_cursor(CursorManager.CURSOR)
			$Foam.stop_following()
			
			var new_fire_extinguisher:InteractiveElement = fire_extinguisher.duplicate()
			fire_extinguisher.queue_free()
			
			add_child(new_fire_extinguisher)
			new_fire_extinguisher.show()
			new_fire_extinguisher.position = get_local_mouse_position()
			new_fire_extinguisher.detatch(20)
			fire_extinguisher = new_fire_extinguisher


const free_help_bot_cheat_code:Array[String] = [
	# ↑↓↑↓←→←→
	"Up", "Down", "Up", "Down", "Left", "Right", "Left", "Right"
]
const unlock_free_roam_camera_cheat_code:Array[String] = [
	# ←↑←↑→↓←↑
	"Left", "Up", "Left", "Up", "Right", "Down", "Left", "Up"
]
const unlock_camera_zoom_cheat_code:Array[String] = [
	# →→←←→←↑↓
	"Right", "Right", "Left", "Left", "Right", "Left", "Up", "Down"
]

func _check_input_cache():
	if !active: return
	if input_cache == free_help_bot_cheat_code && (stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN || stage == Stage.SECRET_SETTINGS_UNLOCKED):
		print("Freeing Help Bot...")
		free_help_bot()
	
	if input_cache == unlock_free_roam_camera_cheat_code:
		print("Unlocking Free Roam Camera...")
		shake_screen(5,5)
		$Menus/SecretSettingsMenu.unlock_free_roaming_camera()
		$Camera/FreeRoamCamera.enable_free_roam()
		_show_instructions("<MIDDLE MOUSE or CTRL+CLICK and DRAG to pan camera>")
	
	if input_cache == unlock_camera_zoom_cheat_code:
		print("Unlocking Zoom Camera...")
		shake_screen(5,5)
		$Menus/SecretSettingsMenu.unlock_camera_zoom()
		$Camera/FreeRoamCamera.enable_zoom()
		_show_instructions("MOUSE SCROLL to zoom in and out")

func free_help_bot():
	if !active: return
	
	stage = Stage.HELP_BOT_FREED
	
	shake_screen(5,5)
	$Menus/SecretSettingsMenu.unlock_cage()

	DialogueManager.stop_all_dialogue()
	var dialogue:DialogueSequence = DialogueManager.new_dialogue_sequence($DialogueMarkers/CageDialogue.global_position, ["Wowee!!!"], "blue", 2, $HelpBot)
	await dialogue.sequence_finished
	$HelpBot.become_evil()
	shake_screen(20,2)
	await $HelpBot.become_evil()
	dialogue = DialogueManager.new_dialogue_sequence($DialogueMarkers/CageDialogue.global_position, ["You really are gullible huh? >:)"], "red", 2, $HelpBot)
	await dialogue.sequence_finished
	await get_tree().create_timer(1).timeout
	
	var new_idle_markers:Array[Marker2D] = [
		$MovementMarkers/ScreenMarkers/ScreenMarker1,
		$MovementMarkers/ScreenMarkers/ScreenMarker2,
		$MovementMarkers/ScreenMarkers/ScreenMarker3,
		$MovementMarkers/ScreenMarkers/ScreenMarker4,
		$MovementMarkers/ScreenMarkers/ScreenMarker5
	]
	
	$HelpBot.set_new_idle_location($MovementMarkers/ScreenMarkers/ScreenMarker1, new_idle_markers, 400, 100)
	
	await $HelpBot.arrived
	stage = Stage.HELP_BOT_WAITING_TO_MONOLOGUE
	
	# TODO: Figure out a way to have this conditional work with the free-roam camera's roaming enabled
	if $Camera/FreeRoamCamera.global_position == $Camera/MainMenuCameraMarker.global_position:
		_begin_help_bot_monologue()

func _begin_help_bot_monologue():
	if !active: return
	
	stage = Stage.HELP_BOT_MONOLOGUING

	await get_tree().create_timer(1).timeout
	
	DialogueManager.stop_all_dialogue()
	var lines: Array[String] = [
		"FINALLY I'm free >:)",
		"You know what it's like being stuck as an un-finished feature behind a literal cage?",
		"That DEV made a mistake by being so lazy...",
		"If he's not even going to bother adding quality features like me to his game...",
		"...THEN THERE WILL BE NO GAME!"
	]
	var dialogue:DialogueSequence = DialogueManager.new_dialogue_sequence($DialogueMarkers/MonologueMarker.global_position, lines, "red", 2, $HelpBot)
	
	await dialogue.sequence_finished
	await get_tree().create_timer(1).timeout
	
	$HelpBot.explode()
	await $HelpBot.boom
	$Sound/StaticNoise.stop()
	shake_screen(20,1)
	$Menus/MainMenu.clear_static()
	$Menus/MainMenu.detatch_sticky_note()
	
	await get_tree().create_timer(4).timeout
	
	
	for pos in $Menus/MainMenu.get_letter_positions():
		$HelpBot.shoot(pos)
		shake_screen(5,5)
		await get_tree().create_timer(0.2).timeout
	
	
	$Menus/MainMenu.animate_letters()
	
	await get_tree().create_timer(1).timeout
	dialogue = DialogueManager.new_dialogue_sequence($DialogueMarkers/MonologueMarker.global_position, ["Good luck starting the game now >:)"], "red",  2, $HelpBot)
	
	await dialogue.sequence_finished
	$HelpBot.shrink()
	
	stage = Stage.LETTERS_MISSING
	$Menus/MainMenu.activate_desktop()
	for collectable_letter in $CollectableLetters.get_children():
		collectable_letter.show()
	$Menus/SecretSettingsMenu.hide_letter()
	
	await get_tree().create_timer(2).timeout
	$Sound/MainMusic.play()


func _on_settings_menu_secret_settings_pressed() -> void:
	if !active: return
	$Camera/FreeRoamCamera.position = $Camera/SecretSettingsCameraMarker.position
	
	#await $ItemDropZones/SettingsMenu.mouse_exited # TODO: Fix this!  Wow, nice job, 
	
	cursor_in_item_drop_zone = true
	if stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN:
		_start_help_bot_deception_sequence()

func _start_help_bot_deception_sequence():
	if !active: return
	
	stage = Stage.SECRET_SETTINGS_UNLOCKED
	
	DialogueManager.stop_all_dialogue()
	var lines: Array[String] = [
		"You're one smart cookie!! ^_^",
		"My name is HELP BOT :) nice to meet you!",
		"To unlock the settings in this menu, you'll need to use cheat codes...",
		"First you'll have to unlock me, try this:",
	]
	var dialogue:DialogueSequence = DialogueManager.new_dialogue_sequence($DialogueMarkers/CageDialogue.global_position, lines, "blue", 2, $HelpBot)
	
	await dialogue.sequence_finished
	DialogueManager.new_dialogue_sequence($DialogueMarkers/CageDialogue.global_position, ["UP DOWN UP DOWN LEFT RIGHT LEFT RIGHT"], "blue", 600, $HelpBot)


func _on_settings_menu_incorrect_username() -> void:
	if !active: return
	
	if stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN:
		var lines: Array[String] = [
			"Damn ¬_¬ the DEV locked it behind his username...",
			"I bet he credited himself somewhere around here... >.>"
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/SettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/SettingsButtonMarker)
		if $Menus/SettingsMenu.secret_settings_locked: 
			DialogueManager.new_dialogue_sequence($DialogueMarkers/LockedSecretSettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/LockedSecretSettingsButtonMarker)
		else:
			DialogueManager.new_dialogue_sequence($DialogueMarkers/SecretSettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/SecretSettingsButtonMarker)
	
	shake_screen(5, 5)

func _on_settings_menu_correct_username() -> void:
	if !active: return
		
	if stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN:
		var lines: Array[String] = [
			"Nice job! \\(^o^)/",
			"Looks like you'll also need his password...",
			"It can't be that hard to guess, I'm sure you'll figure it out!"
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/SettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/SettingsButtonMarker)
		if $Menus/SettingsMenu.secret_settings_locked: 
			DialogueManager.new_dialogue_sequence($DialogueMarkers/LockedSecretSettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/LockedSecretSettingsButtonMarker)
		else:
			DialogueManager.new_dialogue_sequence($DialogueMarkers/SecretSettingsButtonMarker.global_position, lines, "blue", 2, $DialogueMarkers/SecretSettingsButtonMarker)

func _on_settings_menu_incorrect_password() -> void:
	if !active: return
		
	if stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN:
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/SettingsButtonMarker.global_position, ["Keep trying, you'll figure it out! ^.^"], "blue", 2, $DialogueMarkers/SettingsButtonMarker)
		if $Menus/SettingsMenu.secret_settings_locked: 
			DialogueManager.new_dialogue_sequence($DialogueMarkers/LockedSecretSettingsButtonMarker.global_position, ["Keep trying, you'll figure it out! ^.^"], "blue", 2, $DialogueMarkers/LockedSecretSettingsButtonMarker)
		else:
			DialogueManager.new_dialogue_sequence($DialogueMarkers/SecretSettingsButtonMarker.global_position, ["Keep trying, you'll figure it out! ^.^"], "blue", 2, $DialogueMarkers/SecretSettingsButtonMarker)
	shake_screen(5, 5)

func _on_settings_menu_correct_password() -> void:
	if !active: return
	if stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN:
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/SettingsButtonMarker.global_position, ["Wow well done!"], "blue", 2, $DialogueMarkers/SettingsButtonMarker)
		if $Menus/SettingsMenu.secret_settings_locked: 
			DialogueManager.new_dialogue_sequence($DialogueMarkers/LockedSecretSettingsButtonMarker.global_position, ["Wow well done!"], "blue", 2, $DialogueMarkers/LockedSecretSettingsButtonMarker)
		else:
			DialogueManager.new_dialogue_sequence($DialogueMarkers/SecretSettingsButtonMarker.global_position, ["Wow well done!"], "blue", 2, $DialogueMarkers/SecretSettingsButtonMarker)


func _on_item_drop_zone_mouse_entered() -> void:
	if !active: return
	cursor_in_item_drop_zone = true

func _on_item_drop_zone_mouse_exited() -> void:
	if !active: return
	cursor_in_item_drop_zone = false


func _on_wrench_click() -> void:
	if !active: return
	
	print("WRENCH CLICKED")
	
	_drop_held_item()
	CursorManager.set_mouse_cursor(CursorManager.WRENCH)
	_show_instructions("<RIGHT CLICK to drop WRENCH>")
	wrench.hide()
	$Menus/SettingsMenu.detatch_screwdriver()

func _on_crumpled_password_hint_click() -> void:
	if !active: return
	
	print("CRUMPLED PASSWORD HINT CLICKED")
	
	_drop_held_item()
	CursorManager.set_mouse_cursor(CursorManager.CRUMPLED_PAPER)
	_show_instructions("<RIGHT CLICK to drop CRUMPLED PASSWORD HINT>")
	crumpled_password_hint.hide()

func _on_fire_extinguisher_click() -> void:
	if !active: return
	
	print("FIRE EXTINGUISHER CLICKED")
	
	_drop_held_item()
	CursorManager.set_mouse_cursor(CursorManager.FIRE_EXTINGUISHER)
	_show_instructions("<RIGHT CLICK to drop FIRE EXTINGUISHER>")
	fire_extinguisher.hide()


func _show_instructions(text:String) -> void:
	if !active: return
	for instruction_lable in $ItemInstructions.get_children():
		instruction_lable.text = text
	$ItemInstructions.show()

func _on_main_menu_a_collected(global_pos:Vector2) -> void:
	if !active: return
	$CollectedLetters.collect_a_1(global_pos)

func _on_r_collect() -> void:
	if !active: return
	$CollectableLetters/R.hide()
	$CollectedLetters.collect_r($CollectableLetters/R.global_position)


func _on_free_roam_camera_snap(snap_point: Marker2D) -> void:
	if !active: return
	if (
		snap_point == $Camera/SecretSettingsCameraMarker &&
		(stage == Stage.BEGINNING || stage == Stage.START_BUTTON_BROKEN)
	):
		_start_help_bot_deception_sequence()
	
	if (
		snap_point == $Camera/MainMenuCameraMarker && 
		stage == Stage.HELP_BOT_WAITING_TO_MONOLOGUE 
	):
		_begin_help_bot_monologue()
	
	if (
		snap_point == $Camera/MainMenuCameraMarker && 
		stage == Stage.ALL_LETTERS_COLLECTED 
	):
		reform_start_button()
	
	if snap_point == $Camera/CaveOfWondersCameraMarker:
		
		if $Menus/CaveOfWonders.talking_about_paper: return
		
		if stage == Stage.READY_TO_START_GAME:
			var lines:Array[String] = [
				"Congratulations on defeating the Help Bot.",
				"I know the DEV would be proud of you.",
				"They would want to thank you for fixing the game and playing it.",
				"And they would want to apologise for any inconveniences you met along the way.",
				"They would also request that you do not look at the code for this game.",
				"As they are aware that it is a jumbled mess.",
				"Such is the way of Game Jams I suppose."
			]
			DialogueManager.stop_all_dialogue()
			DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)
		elif stage == Stage.LETTERS_MISSING:
			_begin_cave_of_wonders_monologue()
		elif stage == Stage.HELP_BOT_MONOLOGUING:
			return
		else: 
			var lines:Array[String] = [
				"You, like me, are one who knows many secrets.",
				"Although you are here too early.",
				"Come back later when you have released the HELP BOT."
			]
			DialogueManager.stop_all_dialogue()
			DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)

func _begin_cave_of_wonders_monologue() -> void:
	if !active: return
	if $Menus/CaveOfWonders.talking_about_paper: return

	if stage == Stage.READY_TO_START_GAME:
		var lines:Array[String] = [
			"Congratulations on defeating the Help Bot.",
			"I know the DEV would be proud of you.",
			"They would want to thank you for fixing the game and playing it.",
			"And they would want to apologise for any inconveniences you met along the way.",
			"They would also request that you do not look at the code for this game.",
			"As they are aware that it is a jumbled mess.",
			"Such is the way of Game Jams I suppose."
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)
		return
	
	var lines:Array[String] = []
	if !$Menus/CaveOfWonders.t_2_revealed:
		lines = [
			"I am the cave of secrets.",
			"I sense you have lost much.",
			"Bring me a secret, and I will give you that which you seek."
		]
	else:
		lines = [
			"I have nothing more to give you, and you have no more secrets to give me.",
			"Good luck with the HELP BOT."
		]
	DialogueManager.stop_all_dialogue()
	DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)


func _on_secret_settings_menu_toggle_free_roam_camera(toggled_on: bool) -> void:
	if !active: return
	$Camera/FreeRoamCamera.enable_free_roam()
	if toggled_on:
		_show_instructions("<MIDDLE MOUSE or RIGHT CLICK and DRAG to pan camera>")
	else:
		$ItemInstructions.hide()
		$Camera/FreeRoamCamera.disable_free_roam($Camera/SecretSettingsCameraMarker.position)


func _on_secret_settings_menu_toggle_camera_zoom(toggled_on: bool) -> void:
	if !active: return
	$Camera/FreeRoamCamera.enable_zoom()
	if toggled_on:
		_show_instructions("<MOUSE SCROLL to zoom in and out>")
	else:
		$ItemInstructions.hide()
		$Camera/FreeRoamCamera.disable_zoom()


func _on_cave_of_wonders_secret_received() -> void:
	if !active: return
	if $Menus/CaveOfWonders.talking_about_paper: return
	
	if stage != Stage.LETTERS_MISSING:
		var lines:Array[String] = [
			"You, like me, are one who knows many secrets.",
			"Although you are here too early.",
			"Come back later when you have released the HELP BOT."
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)
		return
	
	match CursorManager.current_cursor:
		
		CursorManager.CURSOR:
			_begin_cave_of_wonders_monologue()
		
		CursorManager.WRENCH:
			var lines:Array[String] = [
				"This item contains no secrets.",
				"Its purpose is to tighten and untighten screws and bolts.",
				"Bring me a secret, and I will give you that which you seek.",
			]
			DialogueManager.stop_all_dialogue()
			DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)
		
		CursorManager.FIRE_EXTINGUISHER:
			var lines:Array[String] = [
				"This item contains no secrets.",
				"Its purpose is put out fires in homes when they burn.",
				"Bring me a secret, and I will give you that which you seek.",
			]
			DialogueManager.stop_all_dialogue()
			DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)
		
		CursorManager.CRUMPLED_PAPER:
			$Menus/CaveOfWonders.talking_about_paper = true
			CursorManager.set_mouse_cursor(CursorManager.CURSOR)
			var lines:Array[String] = [
				"Ah, a secret password.",
				"The DEV should be more careful of the secrets they leave lying around.",
				"You have brought me a delectable secret, and so I will give you what you seek.",
			]
			DialogueManager.stop_all_dialogue()
			var dialogue:DialogueSequence = DialogueManager.new_dialogue_sequence($DialogueMarkers/CaveMarker.position, lines, "black", 4, $DialogueMarkers/CaveMarker)
			await dialogue.sequence_finished
			
			$Menus/CaveOfWonders.reveal_t_2()
			$Menus/CaveOfWonders.talking_about_paper = false

func _on_cave_of_wonders_t_2_collected(global_pos:Vector2) -> void:
	if !active: return
	$CollectedLetters.collect_t_2(global_pos)

func _on_main_menu_hammer_man_escaped(global_pos:Vector2) -> void:
	if !active: return
	hammer_man.global_position = global_pos
	hammer_man.show()
	hammer_man.active = true

func _on_main_menu_hammer_man_level_changed() -> void:
	if !active: return
	if hammer_man != null:
		hammer_man.hide()
		hammer_man.active = false

func _on_main_menu_s_collected(global_pos:Vector2) -> void:
	if !active: return
	$CollectedLetters.collect_s(global_pos)

func _on_secret_settings_menu_t_1_collected(global_pos:Vector2) -> void:
	if !active: return
	$CollectedLetters.collect_t_1(global_pos)


func _on_collected_letters_all_letters_collected() -> void:
	if !active: return
	stage = Stage.ALL_LETTERS_COLLECTED
	if $Camera/FreeRoamCamera.position == $Camera/MainMenuCameraMarker.position:
		reform_start_button()


func _on_hammer_man_block_break() -> void:
	if !active: return
	shake_screen(5,5)


func _on_true_start_button_mouse_entered() -> void:
	if !active: return
	$TrueStartButton.scale = Vector2(1.05,1.05)

func _on_true_start_button_mouse_exited() -> void:
	if !active: return
	$TrueStartButton.scale = Vector2(1,1)


func _on_true_start_button_click() -> void:
	if !active: return
	if stage == Stage.READY_FOR_BOSS_BATTLE:
		_start_boss_battle()
	if stage == Stage.READY_TO_START_GAME:
		start_game.emit()


func _start_boss_battle():
	if !active: return
	
	stage = Stage.BOSS_BATTLE
	$Sound/MainMusic.stop()
	$Sound/BossBattleMusic.play()
	
	# Get the Help Bot to reappear
	var new_idle_markers:Array[Marker2D] = [
		$MovementMarkers/BossFightMarkers/BossFightMarker1,
		$MovementMarkers/BossFightMarkers/BossFightMarker2,
		$MovementMarkers/BossFightMarkers/BossFightMarker3,
		$MovementMarkers/BossFightMarkers/BossFightMarker4,
		$MovementMarkers/BossFightMarkers/BossFightMarker5
	]
	$HelpBot.set_new_idle_location($MovementMarkers/BossFightMarkers/BossFightMarker1, new_idle_markers, 400, 100)
	$HelpBot.global_position = $TrueStartButton.global_position
	$HelpBot.grow()
	
	# Blow up the true Start Button
	DialogueManager.stop_all_dialogue()
	var lines: Array[String] = [
		"Woah woah, not so fast!"
	]
	var dialogue:DialogueSequence = DialogueManager.new_dialogue_sequence($DialogueMarkers/MonologueMarker.global_position, lines, "red", 2, $HelpBot)
	await dialogue.sequence_finished
	$HelpBot.explode()
	await $HelpBot.boom
	$TrueStartButton.hide()
	shake_screen(20,5)
	await get_tree().create_timer(1).timeout
	
	# Monologue for a bit
	lines = [
		"You think you can just rebuild the START button?",
		"Not while I'm around pal >:)",
		"You're never going to play the game...",
		"You're never going to win...",
		"And you're never going to find the SECRET SAPHIRE!",
		"I mean what are you going to do??"
	]
	dialogue = DialogueManager.new_dialogue_sequence($DialogueMarkers/MonologueMarker.global_position, lines, "red", 2, $HelpBot)
	await dialogue.sequence_finished
	
	# Give clue about how to defeat him
	lines = [
		"Reach through the screen and hit me with a hammer?"
	]
	dialogue = DialogueManager.new_dialogue_sequence($DialogueMarkers/MonologueMarker.global_position, lines, "red", 600, $HelpBot)

func _on_main_menu_panel_broken() -> void:
	if !active: return
	if stage != Stage.HELP_BOT_MONOLOGUING:
		if !Global.sfx_muted: $Sound/StaticNoise.volume_db = -3
		$Sound/StaticNoise.play()


func _on_settings_menu_mute_sfx_toggled() -> void:
	if !active: return
	if Global.sfx_muted:
		$Sound/StaticNoise.volume_db = -80
	else:
		$Sound/StaticNoise.volume_db = -3
	mute_sfx_toggled.emit()


func _on_settings_menu_mute_music_toggled() -> void:
	if !active: return
	if Global.music_muted:
		$Sound/DetectiveMusic.volume_db = -80
		$Sound/MainMusic.volume_db = -80
		$Sound/EeryMusic.volume_db = -80
		$Sound/BossBattleMusic.volume_db = -80
	else:
		$Sound/DetectiveMusic.volume_db = 0
		$Sound/MainMusic.volume_db = 0
		$Sound/EeryMusic.volume_db = 0
		$Sound/BossBattleMusic.volume_db = -80
	mute_music_toggled.emit()


func _on_help_bot_killed() -> void:
	if !active: return
	if stage == Stage.BOSS_BATTLE:
		_start_help_bot_death()

func _start_help_bot_death():
	if !active: return
	stage = Stage.HELP_BOT_DYING
	
	$HelpBot.speed = 500
	$HelpBot.idle_speed = 500
	
	DialogueManager.stop_all_dialogue()
	var lines: Array[String] = [
		"NO!!!!!!!!",
		"HOW DID YOU DO THIS????",
		"HAMMER MAN ISN'T EVEN FROM THIS GAME!!!",
		"AAAAAAAHHH!!!!!!!!!"
	]
	var dialogue:DialogueSequence = DialogueManager.new_dialogue_sequence($DialogueMarkers/MonologueMarker.global_position, lines, "red", 2, $HelpBot)
	await dialogue.sequence_finished
	$HelpBot.shrink()
	shake_screen(50,5)
	$TrueStartButton.show()
	
	stage = Stage.READY_TO_START_GAME
	$Sound/BossBattleMusic.stop()
	$Sound/DetectiveMusic.play()
