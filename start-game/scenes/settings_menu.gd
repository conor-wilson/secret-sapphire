extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UsernameBox.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_secret_settings_button_pressed() -> void:
	$UsernameBox.show()
	$UsernameBox.grab_focus()

func _on_username_box_text_submitted(new_text: String) -> void:
	print("Username Entered: ", new_text)
	$UsernameBox.clear()
