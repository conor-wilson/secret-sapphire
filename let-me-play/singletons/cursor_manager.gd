extends Node

@onready var CURSOR:Resource = preload("res://assets/art/Cursor.png")
@onready var WRENCH:Resource = preload("res://assets/art/Wrench.png")
@onready var FIRE_EXTINGUISHER:Resource = preload("res://assets/art/FireExtinguisher.png")

var current_cursor:Resource

func set_mouse_cursor(source:Resource):
	Input.set_custom_mouse_cursor(source)
	current_cursor = source

func current_cursor_is(source:Resource) -> bool:
	return current_cursor == source
