extends Node2D

var interactable:bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable = true


func _on_screen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	# Confirm that the screen can be interacted with
	if !interactable:
		return
	
	if event.is_pressed() && event.is_action("click"):
		_clear_circle(_get_mouse_cell_coords())
		

func _get_mouse_cell_coords() -> Vector2i:
	var coords:Vector2 = get_global_mouse_position() 
	return Vector2i(
		floor(coords.x/32),
		floor(coords.y/32),
	)

const circle_matrix:Array[Vector2i] = [
						 Vector2i(-1,-2), Vector2i(0,-2), Vector2i(1,-2),
		Vector2i(-2,-1), Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(2,-1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
						 Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
	]

func _clear_circle(origin:Vector2i):
	for coords in circle_matrix:
		$Static.erase_cell(coords+ origin)
	
