class_name DialogueSequence extends Node2D

@onready var dialogue_box_scene = preload("res://scenes/dialogue_box.tscn")

var dialogue_box # The current instantiation of the dialogue box scene that is being displayed.
var line_queue: Array[String] = [] # The list of lines that are queued to be displayed.

# TODO: Find a way to get rid of the below vars. They feel unnecessary.
var dialogue_linger_time: float = 2

# start_dialogue starts the dialogue sequence, displaying the provided lines one
# by one at the provided position. The optional linger_time input determines the
# amount of seconds that each line should stay on the screen before moving on.
func start_dialogue(position: Vector2, lines: Array[String], linger_time:float=2): 
	
	# Exit early if there's already an active dialogue box
	if dialogue_box != null:
		return
	
	# Set the class-scoped components
	self.position = position
	line_queue = lines
	dialogue_linger_time = linger_time
	
	# Start the dialogue
	_show_dialogue_box()

# _show_dialogue_box removes any existing dialogue box, and creates a new one
# containing the next line in the queue, if it exists.
func _show_dialogue_box():
	
	# Exit early if we're all out of lines in the queue
	if line_queue.size() == 0:
		return
	
	# Instantiate a new dialogue box
	dialogue_box = dialogue_box_scene.instantiate()
	get_tree().root.add_child(dialogue_box)
	
	# Rig the box up to work as it should
	dialogue_box.finished_displaying.connect(_on_dialogue_box_finished_displaying)
	dialogue_box.global_position = position
	
	# Display the next text in the queue
	dialogue_box.display_text(line_queue.pop_front())

# _on_dialogue_box_finished_displaying waits for the designated 
# dialogue_linger_time, and then advances the dialogue to the next line (or
# clears the dialogue box).
func _on_dialogue_box_finished_displaying():
	await get_tree().create_timer(dialogue_linger_time).timeout
	_advance_dialogue()

# _advance_dialogue() clears the current dialogue box, and spawns a new one with
# the next line in the queue if one exists.
func _advance_dialogue() -> void:
	
	# Check to see if the sequence has completed
	if dialogue_box == null:
		queue_free()
		return
	
	dialogue_box.queue_free()
	_show_dialogue_box()
