extends Node2D

signal back_button

@export var devUsername := "QuietLantern"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UsernameBox.hide()
	$PasswordBox.hide()

func _on_secret_settings_button_pressed() -> void:
	$UsernameBox.show()
	$UsernameBox.grab_focus()

func _on_username_box_text_submitted(new_text: String) -> void:
	print("Username Entered: ", new_text)
	$UsernameBox.clear()
	
	if new_text == devUsername:
		$PasswordBox.show()
		$PasswordBox.grab_focus()

func _on_password_box_text_submitted(new_text: String) -> void:
	print("Password Entered: ", new_text)
	$PasswordBox.clear()

func _on_button_pressed() -> void:
	back_button.emit()
