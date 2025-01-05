extends Node2D

signal back_pressed
signal secret_settings_pressed
signal correct_username
signal incorrect_username
signal correct_password
signal incorrect_password
signal mute_sfx_toggled
signal mute_music_toggled

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
	if !Global.sfx_muted: $Sound/SelectNoise.play()
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
		ScreenShakeManager.shake_screen(5, 5)

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
		ScreenShakeManager.shake_screen(5, 5)

func _on_back_button_pressed() -> void:
	if !Global.sfx_muted: $Sound/SelectNoise.play()
	back_pressed.emit()
	username_box.release_focus()
	password_box.release_focus()

func detatch_screwdriver():
	_detatch_element_if_exists("InteractiveElements/Screwdriver", 10)

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

func _on_mute_sfx_button_box_toggled(toggled_on: bool) -> void:
	Global.sfx_muted = toggled_on
	mute_sfx_toggled.emit()

func _on_mute_music_button_box_toggled(toggled_on: bool) -> void:
	Global.music_muted = toggled_on
	mute_music_toggled.emit()
