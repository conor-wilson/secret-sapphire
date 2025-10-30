class_name DialogueBox extends MarginContainer

# TODO: Review this code and tidy it all up
# TODO: Make it so the pitch can be scaled via an exported var so that cave of wonders has a deeper voice

@onready var label: Label = $VBoxContainer/MarginContainer/MarginContainer/Label
@onready var timer: Timer = $Timer
@onready var nine_patch_rect: NinePatchRect = $VBoxContainer/MarginContainer/NinePatchRect
@onready var click_box: Button = $ClickBox
@onready var click_box_collision_shape: CollisionShape2D = $ClickBox/CollisionShape2D

var pitch_modifier:float = 1

var follow_node:CanvasItem = null

var line_queue: Array[String] = [] # The list of lines that are queued to be displayed.

const MAX_WIDTH = 288

var text = ""
var letter_index = 0

const BLUE_BOX:Texture2D  = preload("res://assets/art/dialogue/DialogueBox.png")
const RED_BOX:Texture2D   = preload("res://assets/art/dialogue/DialogueBox_Red.png")
const BLACK_BOX:Texture2D = preload("res://assets/art/dialogue/DialogueBox_black.png")

var letter_time = 0.03
var space_time = 0.06
var punc_time = 0.2
signal finished_displaying

signal clicked
var skipped:bool = false
var done:bool = false

# TODO: This is just so janky... create a proper constructor when there is time
func set_colour(colour:String):
	match colour:
		"red":
			nine_patch_rect.texture = RED_BOX
			label.add_theme_color_override("font_color", Color("ac3232"))
			$VBoxContainer/TabInstructions/Label.add_theme_color_override("font_color", Color("ac3232"))
			pitch_modifier = 0.75
		"blue":
			nine_patch_rect.texture = BLUE_BOX
			label.add_theme_color_override("font_color", Color("3f3f74"))
			$VBoxContainer/TabInstructions/Label.add_theme_color_override("font_color", Color("3f3f74"))
			pitch_modifier = 1
		"black":
			nine_patch_rect.texture = BLACK_BOX
			label.add_theme_color_override("font_color", Color("000000"))
			$VBoxContainer/TabInstructions/Label.add_theme_color_override("font_color", Color("000000"))
			pitch_modifier = 0.5
		_: 
			nine_patch_rect.texture = BLUE_BOX
			label.add_theme_color_override("font_color", Color("3f3f74"))
			$VBoxContainer/TabInstructions/Label.add_theme_color_override("font_color", Color("3f3f74"))
			pitch_modifier = 0.5

func _process(delta: float) -> void:
	_follow_node_if_exists()
	#_resize_click_box()

func _follow_node_if_exists():
	if follow_node != null:
		position = follow_node.position + Vector2(48, 16)

func display_text(new_text:String):
	
	_follow_node_if_exists() # TODO: Does this need to be here? Doubt it. 
	
	text = new_text
	label.text = new_text
	skipped = false
	done = false
	
	await resized
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # Wait for x resize
		await resized # Wait for y resize
		custom_minimum_size.y = size.y
	
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24 
	
	label.text = ""
	if skipped: 
		_skip_to_end()
	else:
		_display_letter()

func _display_letter():
	
	$BlipNoise.pitch_scale = randf_range(pitch_modifier-0.05,pitch_modifier+0.05)
	if !Global.sfx_muted: $BlipNoise.play()
	
	_follow_node_if_exists() # TODO: Does this need to be here? Doubt it. 
	label.text += text[letter_index]
	
	letter_index += 1 
	if letter_index >= text.length():
		finished_displaying.emit()
		done = true
		return
	
	match text[letter_index]: 
		"!", ".", ",", "?":
			timer.start(punc_time)
		" ": 
			timer.start(space_time)
		_:
			timer.start(letter_time)

func skip_to_end() -> void:
	skipped = true

# _skip_to_end skips the dialogue to the end of the current text string.
func _skip_to_end() -> void:
	
	$BlipNoise.pitch_scale = randf_range(pitch_modifier-0.05,pitch_modifier+0.05)
	if !Global.sfx_muted: $BlipNoise.play()
	
	_follow_node_if_exists() # TODO: Does this need to be here? Doubt it. 
	label.text = text
	
	letter_index = text.length()
	finished_displaying.emit()
	done = true

func _on_timer_timeout() -> void:
	_follow_node_if_exists() # TODO: Does this need to be here? Doubt it. 
	if skipped: 
		_skip_to_end()
	else:
		_display_letter()


## Click box functionality

#func _on_nine_patch_rect_resized() -> void:
	#_resize_click_box()
#
#func _resize_click_box() -> void:
	#$ClickBox/CollisionShape2D.shape.size = $VBoxContainer/MarginContainer/NinePatchRect.size
	#$ClickBox/CollisionShape2D.global_position.x = $VBoxContainer/MarginContainer/NinePatchRect.global_position.x + $VBoxContainer/MarginContainer/NinePatchRect.size.x/2
	#$ClickBox/CollisionShape2D.global_position.y = $VBoxContainer/MarginContainer/NinePatchRect.global_position.y + $VBoxContainer/MarginContainer/NinePatchRect.size.y/2

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()



## BELOW: Tab instruction experimentation functionality
# TODO: Figure out how to make this (or something like it) work
# NOTE: Maybe a setting called "tab to skip dialogue"?

func show_tab_instructions() -> void:
	await get_tree().create_timer(0.4).timeout
	$VBoxContainer/TabInstructions/BlinkerTimer.start()
	$VBoxContainer/TabInstructions.hide()
	$VBoxContainer/TabInstructions/Label.show()
	$VBoxContainer/TabInstructions/BlinkerTimer.start()
	$VBoxContainer/TabInstructions/Label.show()

func hide_tab_instructions() -> void:
	$VBoxContainer/TabInstructions.hide()

func _on_blinker_timer_timeout() -> void:
	if $VBoxContainer/TabInstructions/Label.visible:
		$VBoxContainer/TabInstructions/Label.hide()
	else:
		$VBoxContainer/TabInstructions/Label.show()


func _on_click_box_button_down() -> void:
	clicked.emit()
