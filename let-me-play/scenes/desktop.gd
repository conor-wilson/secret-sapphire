extends Node2D

var interactable:bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable = false


func _on_screen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	# Confirm that the screen can be interacted with
	if !interactable:
		return
	
	if event.is_pressed() && event.is_action("click"):
		var coords = _get_mouse_cell_coords()
		$Static.erase_cell(coords)

func _get_mouse_cell_coords() -> Vector2i:
	var coords:Vector2 = get_global_mouse_position() 
	return Vector2i(
		floor(coords.x/32),
		floor(coords.y/32),
	)
