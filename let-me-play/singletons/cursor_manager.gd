extends Node

@onready var CURSOR:Resource = preload("res://assets/art/Cursor.png")
@onready var WRENCH:Resource = preload("res://assets/art/Wrench.png")

func set_mouse_cursor(source:Resource):
	Input.set_custom_mouse_cursor(source)
