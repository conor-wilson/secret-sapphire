extends Node2D

signal back_pressed
signal shake_screen(strength:float, fade:float)
signal secret_settings_unlocked

# TODO: Implement a generic way to check case-insentitively
var accepted_usernames:Array[String] = [
	"QuietLantern",
	"quietlantern",
	"quietLantern",
	"QUIETLANTERN",
	"@QuietLantern",
	"@quietlantern",
	"@quietLantern",
	"@QUIETLANTERN",
]

var accpted_passwords:Array[String] = [
	"turtle123",
	"Turtle123",
	"TURTLE123",
	"turtles123",
	"Turtles123",
	"TURTLES123",
]

@onready var username_box: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/UsernameBox
@onready var password_box: LineEdit = $CenterContainer/MarginContainer/VBoxContainer/PasswordBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	username_box.hide()
	password_box.hide()
	$HelpBot.become_evil()
	$HelpBot.hide()
	$HelpBot.speed = 0

func _on_secret_settings_button_pressed() -> void:
	username_box.show()
	username_box.grab_focus()

func _on_username_box_text_submitted(new_text: String) -> void:
	print("Username Entered: ", new_text)
	
	if _correct_input(new_text, accepted_usernames):
		password_box.show()
		password_box.grab_focus()
		
		var lines: Array[String] = [
			"Nice job! \\(^o^)/",
			"Looks like, you'll also need his password...",
			"It can't be that hard to guess, I'm sure you'll figure it out!"
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/WrongPasswordMarker.global_position, lines)
	else:
		username_box.clear()
		var lines: Array[String] = [
			"Damn ¬_¬ the dev locked it behind his username...",
			"I bet he credited himself somewhere around here... >.>"
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/WrongPasswordMarker.global_position, lines)
		shake_screen.emit(5, 5)

func _on_password_box_text_submitted(new_text: String) -> void:
	print("Password Entered: ", new_text)
	
	if _correct_input(new_text, accpted_passwords):
		# TODO: Here, make it so that the Secret Settings button now just takes 
		# you to the secret settings menu
		secret_settings_unlocked.emit()
	else:
		password_box.clear()
		shake_screen.emit(5, 5)
		var lines: Array[String] = [
			"Keep trying, you'll figure it out! ^.^",
		]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($DialogueMarkers/WrongPasswordMarker.global_position, lines)

func _on_back_button_pressed() -> void:
	back_pressed.emit()
	username_box.release_focus()
	password_box.release_focus()

func _on_settings_icon_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed() && event.is_action("click"):
		print("WRENCH CLICKED")
		CursorManager.set_mouse_cursor(CursorManager.WRENCH)
		$InteractiveElements/SettingsIcon.queue_free()
		
		_detatch_element_if_exists("InteractiveElements/Screwdriver", 10)
		shake_screen.emit(5, 10)

func _on_screwdriver_smash() -> void:
	shake_screen.emit(5,5)

# _correct_input returns true if the provided input string matches any of the
# strings in the provided accpeted_strings array.
func _correct_input(input:String, accepted_strings:Array[String]) -> bool:
	
	for accpeted_string in accepted_strings:
		if input == accpeted_string:
			return true
	
	return false

# TODO: This is a duplicate of the same function in main_menu.gd. Deduplicate
# this.
func _detatch_element_if_exists(path: NodePath, strength:float=1):
	var element := get_node_or_null(path)
	
	# Check that the element can be detatched
	if element == null: return
	if element is not BreakableElement: return
	if !element.idle: return
	
	# Detatch element
	element.detatch(strength)
#
## TODO: This is purely for debugging. This function should be removed once it's
## no-longer needed.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debugbutton"):
		#$HelpBot.show()
		#$HelpBot.grow()
		#await get_tree().create_timer(2.5).timeout
		#$HelpBot.start_leaving()
