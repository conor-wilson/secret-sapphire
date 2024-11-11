extends Node

@onready var dialogue_box_scene = preload("res://scenes/dialogue_box.tscn")

# TODO: Review this code and tidy it all up

var dialogue_lines: Array[String] = []
var current_line_index: int = 0

var dialogue_box
var dialogue_box_position: Vector2

var dialogue_active: bool = false
var can_advance_line: bool = false

func start_dialogue(position: Vector2, lines: Array[String]): 
	if dialogue_active:
		return
	
	dialogue_lines = lines
	dialogue_box_position = position
	_show_dialogue_box()
	
	dialogue_active = true

func _show_dialogue_box(): 
	dialogue_box = dialogue_box_scene.instantiate()
	dialogue_box.finished_displaying.connect(_on_dialogue_box_finished_displaying) # TODO: This seems like a race condition
	get_tree().root.add_child(dialogue_box)
	dialogue_box.global_position = dialogue_box_position
	dialogue_box.display_text(dialogue_lines[current_line_index])
	can_advance_line = false

func _on_dialogue_box_finished_displaying():
	can_advance_line = true

# TODO: Change all the below to be triggered by a timed event rather than via player input.
func _unhandled_input(event: InputEvent) -> void:
	if (
		event.is_action_pressed("advance_dialogue") &&
		dialogue_active &&
		can_advance_line
	): 
		dialogue_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			dialogue_active = false
			current_line_index = 0
			return
		
		_show_dialogue_box()
	
	
