extends Node

@onready var dialogue_sequence_scene = preload("res://scenes/dialogue_sequence.tscn")

# new_dialogue_sequence starts a new dialogue sequence at the provided position,
# displaying a dialogue box with the provided lines. The optional linger_time
# input determines how long the text box lingers for between lines.
func new_dialogue_sequence(position: Vector2, lines: Array[String], linger_time:float=2):
	var sequence = dialogue_sequence_scene.instantiate()
	get_tree().root.add_child(sequence)
	sequence.start_dialogue(position, lines.duplicate(), linger_time)
