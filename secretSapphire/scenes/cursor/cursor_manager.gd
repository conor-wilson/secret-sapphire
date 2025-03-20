extends Node

@onready var CURSOR:Resource = preload("res://assets/art/items/Cursor.png")
@onready var WRENCH:Resource = preload("res://assets/art/items/Wrench.png")
@onready var FIRE_EXTINGUISHER:Resource = preload("res://assets/art/items/FireExtinguisher.png")
@onready var CRUMPLED_PAPER:Resource = preload("res://assets/art/items/CrumpledPaper.png")

var current_cursor:Resource

func set_mouse_cursor(source:Resource):
	Input.set_custom_mouse_cursor(source, 0, _get_hotspot(source))
	current_cursor = source
	

func current_cursor_is(source:Resource) -> bool:
	return current_cursor == source

# _get_hotspot returns the hotspot offset for the provided custom cursor resource.
func _get_hotspot(source:Resource) -> Vector2: 
	match source:
		CURSOR:
			return Vector2.ZERO
		WRENCH:
			return Vector2(4, 4)
		FIRE_EXTINGUISHER: 
			return Vector2(0, 4)
		CRUMPLED_PAPER:
			return Vector2(64, 64)
		_:
			return Vector2.ZERO
