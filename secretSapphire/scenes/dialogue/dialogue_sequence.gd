class_name DialogueSequence extends Node2D

signal line_finished
signal sequence_finished

var follow_node:CanvasItem = null
var skippable:bool = true

var colour:String # TODO: This is jankey. Fix.

@onready var dialogue_box_scene = preload("res://scenes/dialogue/dialogue_box.tscn")

var dialogue_box:DialogueBox # The current instantiation of the dialogue box scene that is being displayed.
var line_queue: Array[String] = [] # The list of lines that are queued to be displayed.

# TODO: Find a way to get rid of the below vars. They feel unnecessary.
@onready var linger_timer: Timer = $LingerTimer

func _process(delta: float) -> void:
	_follow_node_if_exists()
	
func _follow_node_if_exists():
	if follow_node != null:
		position = follow_node.position

# start_dialogue starts the dialogue sequence, displaying the provided lines one
# by one at the provided position. The optional linger_time input determines the
# amount of seconds that each line should stay on the screen before moving on.
func start_dialogue(position: Vector2, lines: Array[String], colour:String, linger_time:float=2, follow:CanvasItem = null, skippable:bool=true): 
	
	# Exit early if there's already an active dialogue box
	if dialogue_box != null:
		return
	
	# Set the class-scoped components
	self.position = position
	line_queue = lines
	linger_timer.wait_time = linger_time
	follow_node = follow
	self.colour = colour
	self.skippable = skippable
	_follow_node_if_exists()
	
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
	dialogue_box.clicked.connect(_on_dialogue_box_clicked)
	dialogue_box.global_position = position
	dialogue_box.follow_node = follow_node
	dialogue_box.set_colour(colour)
	dialogue_box.hide_tab_instructions()
	
	# Display the next text in the queue
	dialogue_box.display_text(line_queue.pop_front())

# _on_dialogue_box_finished_displaying waits for the designated 
# dialogue_linger_time, and then advances the dialogue to the next line (or
# clears the dialogue box).
func _on_dialogue_box_finished_displaying():
	dialogue_box.show_tab_instructions()
	print("Dialogue Box Finished")
	linger_timer.start()

func _on_linger_timer_timeout() -> void:
	_advance_dialogue()

# _advance_dialogue() clears the current dialogue box, and spawns a new one with
# the next line in the queue if one exists.
func _advance_dialogue() -> void:
	
	print("Dialogue Box Started")
	
	line_finished.emit()
	dialogue_box.queue_free()
	
	# Check to see if the sequence has completed
	if line_queue.size() == 0:
		sequence_finished.emit()
		queue_free()
		return
	
	_show_dialogue_box()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue"):
		skip()

func _on_dialogue_box_clicked():
	# NOTE: It's necessary to do it this way so that clicking one dialogue box
	#       skips all current dialogue boxes (this keeps duplicate synchronised)
	DialogueManager.skip_all_dialogue()

func skip():
	if !skippable:
		return
	
	if dialogue_box.done: 
		linger_timer.stop()
		_advance_dialogue()
	else:
		dialogue_box.skip_to_end()
	
