extends Node2D

signal victory

var active:bool = true

var safe_locked:bool = true
var safe_open:bool = false
var picture_on_wall:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset():
	$Safe.show()
	$PictureFrame.show()
	safe_locked = true
	picture_on_wall = true
	safe_open = false
	$Instructions.text = "Find the SECRET SAPPHIRE"

func play():
	show()
	active = true
	$Music.play()

func stop():
	hide()
	active = false
	$Music.stop()

func _on_safe_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_released("click"):
		if safe_locked:
			$Instructions.text = "<SAFE is LOCKED>"
		else:
			safe_open = true
			$Instructions.text = "<The SAFE opens>"
			$Safe.hide()


func _on_picture_frame_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_released("click"):
		$PictureFrame.hide()
		picture_on_wall = false


func _on_red_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_pressed("click") && !picture_on_wall && !safe_open:
		safe_locked = false
		$Instructions.text = "<The SAFE makes a CLICK noise>"
		

func _on_sapphire_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_pressed("click") && safe_open:
		$Instructions.text = "<You have found the SECRET SAPPHIRE!>"
		victory.emit()
		print("GAME WON!")
		
