extends Node2D

signal back_pressed
signal secret_settings_pressed
signal shake_screen(strength:float, fade:float)
signal correct_username
signal incorrect_username
signal correct_password
signal incorrect_password

# TODO: Implement a generic way to check case-insentitively
var accepted_usernames:Array[String] = [
	"QuietLantern",
	"Quietlantern",
	"quietlantern",
	"quietLantern",
	"QUIETLANTERN",
	"@QuietLantern",
	"@Quietlantern",
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

var secret_settings_locked:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lock_secret_settings()

func lock_secret_settings():
	username_box.hide()
	password_box.hide()
	secret_settings_locked = true
	$CenterContainer/MarginContainer/VBoxContainer/SecretSettingsContainer/SecretSettingsButton.text = "<locked>"

func unlock_secret_settings():
	username_box.hide()
	password_box.hide()
	secret_settings_locked = false
	$CenterContainer/MarginContainer/VBoxContainer/SecretSettingsContainer/SecretSettingsButton.text = "secret settings"

func _on_secret_settings_button_pressed() -> void:
	if secret_settings_locked:
		username_box.show()
		username_box.grab_focus()
	else:
		secret_settings_pressed.emit()

func _on_username_box_text_submitted(new_text: String) -> void:
	print("Username Entered: ", new_text)
	
	if _correct_input(new_text, accepted_usernames):
		password_box.show()
		password_box.grab_focus()
		correct_username.emit()
	
	else:
		username_box.clear()
		incorrect_username.emit()

func _on_password_box_text_submitted(new_text: String) -> void:
	print("Password Entered: ", new_text)
	
	if _correct_input(new_text, accpted_passwords):
		# TODO: Here, make it so that the Secret Settings button now just takes 
		# you to the secret settings menu
		unlock_secret_settings()
		correct_password.emit()
	
	else:
		password_box.clear()
		incorrect_password.emit()

func _on_back_button_pressed() -> void:
	back_pressed.emit()
	username_box.release_focus()
	password_box.release_focus()
#
#func move_wrench(new_pos:Vector2):
	#$InteractiveElements/Wrench.show()
	#await get_tree().create_timer(1).timeout
	#$InteractiveElements/Wrench.position = new_pos
	#await get_tree().create_timer(1).timeout
	#_detatch_element_if_exists("InteractiveElements/Wrench", 1)

func detatch_screwdriver():
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
	if element is not InteractiveElement: return
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
