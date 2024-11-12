extends Node

@onready var dialogue_sequence_scene = preload("res://scenes/dialogue_sequence.tscn")

func new_dialogue_sequence(position: Vector2, lines: Array[String], linger_time:float=2):
	var sequence = dialogue_sequence_scene.instantiate()
	get_tree().root.add_child(sequence)
	sequence.start_dialogue(position, lines.duplicate(), linger_time)
