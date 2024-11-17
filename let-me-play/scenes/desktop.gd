extends Node2D

signal tap

var interactable:bool = false 

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#interactable = true


func _on_screen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	# Confirm that the screen can be interacted with
	if !interactable:
		return
	
	if event.is_pressed() && event.is_action("click"):
		_clear_circle(_get_mouse_cell_coords())
		tap.emit()
		

func _get_mouse_cell_coords() -> Vector2i:
	var coords:Vector2 = get_global_mouse_position() 
	return Vector2i(
		floor(coords.x/$Static.tile_set.tile_size.x),
		floor(coords.y/$Static.tile_set.tile_size.y),
	)

const circle_matrix_0:Array[Vector2i] = [
									  Vector2i(-1,-3), 				   Vector2i(1,-3),
					  				   				   				   				   				  
	Vector2i(-3,-1),  				   				   				   				   				   Vector2i(3,-1), 
	 				   				   				   				   				   				   				  
	Vector2i(-3, 1),  				   				   				   				   				   Vector2i(3, 1),
					  				   				   				   				   				  
									  Vector2i(-1, 3),  			   Vector2i(1, 3),
]
const circle_matrix_1:Array[Vector2i] = [
									  				  Vector2i(0,-3), 				 
					 Vector2i(-2,-2), 												   Vector2i(2,-2),
					 				  												   				   				  
	Vector2i(-3, 0), 																				   Vector2i(3, 0),
					 																				   				  
					 Vector2i(-2, 2), 												   Vector2i(2, 2),
									  				  Vector2i(0, 3), 				  
]
const circle_matrix_2:Array[Vector2i] = [
					 Vector2i(-1,-2),                 Vector2i(1,-2),
	Vector2i(-2,-1),                                                  Vector2i(2,-1),
																					 
	Vector2i(-2, 1),                                                  Vector2i(2, 1),
					 Vector2i(-1, 2),                 Vector2i(1, 2),
]
const circle_matrix_3:Array[Vector2i] = [
									  Vector2i(0,-2),                 
																					 
	Vector2i(-2, 0),                                                  Vector2i(2, 0),
																					 
									  Vector2i(0, 2),                 
]
const circle_matrix_4:Array[Vector2i] = [
																	 
					 Vector2i(-1,-1),                 Vector2i(1,-1),                
																					 
					 Vector2i(-1, 1),                 Vector2i(1, 1),                
																	 
]
const circle_matrix_5:Array[Vector2i] = [
																	 
									  Vector2i(0,-1),                                
					 Vector2i(-1, 0),                 Vector2i(1, 0),                
									  Vector2i(0, 1),                                
																	 
]
const circle_matrix_6:Array[Vector2i] = [
																	 
																					 
									  Vector2i(0, 0),                                
																					 
																	 
]
const circle_matrix_full:Array[Vector2i] = [
									  Vector2i(-1,-3), Vector2i(0,-3), Vector2i(1,-3),
					 Vector2i(-2,-2), Vector2i(-1,-2), Vector2i(0,-2), Vector2i(1,-2), Vector2i(2,-2),
	Vector2i(-3,-1), Vector2i(-2,-1), Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(2,-1), Vector2i(3,-1), 
	Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
					 Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
									  Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
]

# _clear_circle clears a circle of static centred at the provided origin point, 
# and then replaces it again with random static tiles.
#
# TODO: This function and the above matrices are HORRIBLY hard-coded. Figure out
# a way to shorten this down and have no-more duplicated code.
func _clear_circle(origin:Vector2i):
	
	# Clear static in a circle
	for coords in circle_matrix_6:
		$Static.erase_cell(coords+origin)
	#await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_5:
		$Static.erase_cell(coords+origin)
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_4:
		$Static.erase_cell(coords+origin)
	#await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_3:
		$Static.erase_cell(coords+origin)
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_2:
		$Static.erase_cell(coords+origin)
	#await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_1:
		$Static.erase_cell(coords+origin)
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_0:
		$Static.erase_cell(coords+origin)
	
	# Rebuild the static in the circle
	await get_tree().create_timer(0.2).timeout
	for coords in circle_matrix_0:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_1:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_2:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_3:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_4:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_5:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in circle_matrix_6:
		$Static.set_cell(coords+origin, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
