extends TileMapLayer

var clearing_all:bool

var circle_matrix_empty = [
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
]
var circle_matrix_full = [
	[0,0,1,1,1,0,0],
	[0,1,1,1,1,1,0],
	[1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1],
	[1,1,1,1,1,1,1],
	[0,1,1,1,1,1,0],
	[0,0,1,1,1,0,0],
]
var circle_matrix_0 = [
	[0,0,1,0,1,0,0],
	[0,0,0,0,0,0,0],
	[1,0,0,0,0,0,1],
	[0,0,0,0,0,0,0],
	[1,0,0,0,0,0,1],
	[0,0,0,0,0,0,0],
	[0,0,1,0,1,0,0],
]
var circle_matrix_1 = [
	[0,0,0,1,0,0,0],
	[0,1,0,0,0,1,0],
	[0,0,0,0,0,0,0],
	[1,0,0,0,0,0,1],
	[0,0,0,0,0,0,0],
	[0,1,0,0,0,1,0],
	[0,0,0,1,0,0,0],
]
var circle_matrix_2 = [
	[0,0,0,0,0,0,0],
	[0,0,1,0,1,0,0],
	[0,1,0,0,0,1,0],
	[0,0,0,0,0,0,0],
	[0,1,0,0,0,1,0],
	[0,0,1,0,1,0,0],
	[0,0,0,0,0,0,0],
]
var circle_matrix_3 = [
	[0,0,0,0,0,0,0],
	[0,0,0,1,0,0,0],
	[0,0,0,0,0,0,0],
	[0,1,0,0,0,1,0],
	[0,0,0,0,0,0,0],
	[0,0,0,1,0,0,0],
	[0,0,0,0,0,0,0],
]
var circle_matrix_4 = [
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,1,0,1,0,0],
	[0,0,0,0,0,0,0],
	[0,0,1,0,1,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
]
var circle_matrix_5 = [
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,1,0,0,0],
	[0,0,1,0,1,0,0],
	[0,0,0,1,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
]
var circle_matrix_6 = [
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,1,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0],
]

func _get_circle_matrix_coords(origin:Vector2i, matrix:Array) -> Array[Vector2i]:
	
	var output:Array[Vector2i] = []
	
	var circle_diameter:int = len(matrix)
	var offset_origin:Vector2i = origin - Vector2i.ONE*circle_diameter/2
	
	for i in range(circle_diameter):
		for j in range(circle_diameter):
			if matrix[i][j]:
				output.append(Vector2i(i,j) + offset_origin)
	
	return output
	

# _clear_circle clears a circle of static centred at the provided origin point, 
# and then replaces it again with random static tiles.
#
# TODO: This function and the above matrices are HORRIBLY hard-coded. Figure out
# a way to shorten this down and have no-more duplicated code.
func clear_static_circle(origin:Vector2i):
	
	# Clear static in a circle
	for coords in _get_circle_matrix_coords(origin, circle_matrix_6):
		erase_cell(coords)
	#await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_5):
		erase_cell(coords)
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_4):
		erase_cell(coords)
	#await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_3):
		erase_cell(coords)
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_2):
		erase_cell(coords)
	#await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_1):
		erase_cell(coords)
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_0):
		erase_cell(coords)
	
	if clearing_all:
		return
	
	# Rebuild the static in the circle
	await get_tree().create_timer(0.2).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_0):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_1):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_2):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_3):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_4):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_5):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout
	for coords in _get_circle_matrix_coords(origin, circle_matrix_6):
		set_cell(coords, 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	await get_tree().create_timer(0.02).timeout


func clear_all_static():
	clearing_all = true
	
	for i in range(100):
		clear_static_circle(Vector2i(randi_range(4,67), randi_range(5,28)))
		#ScreenShakeManager.shake_screen(5,5, clearing_all)
		await get_tree().create_timer(0.005).timeout
	
	#clearing_all = true
	#await get_tree().create_timer(0.5).timeout
	
	var static_tiles :Array[Vector2i]= get_used_cells()
	static_tiles.shuffle()
	
	for i in range(static_tiles.size()): 
		erase_cell(static_tiles[i])
		
		if i%30 == 0:
			await get_tree().create_timer(0.001).timeout
