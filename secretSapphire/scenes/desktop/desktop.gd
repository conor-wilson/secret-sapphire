extends Node2D

signal s_collected(global_pos:Vector2)
signal a_collected(global_pos:Vector2)
signal hammer_man_escaped(global_pos:Vector2)
signal hammer_man_level_changed

var clearing_all:bool

enum Mode {DISABLED, STATIC, ACTIVE}
var mode:Mode = Mode.DISABLED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mode = Mode.DISABLED

const this_is_actually_fine_message:String = "\"THIS ACTUALLY IS FINE!\nTRY THIS:                      \""

func _process(delta: float) -> void:
	
	# Check if A1 is collectable
	$DesktopWindows/TurtleMemeWEBP/A.set_can_collect($DesktopWindows/TurtleMemeWEBP/A/BlockingFire.get_children().size() == 0)
	
	# Check if the fire has been completely doused
	if (
		$DesktopWindows/TurtleMemeWEBP/A/BlockingFire.get_children().size() == 0 &&
		$DesktopWindows/TurtleMemeWEBP/Fire.get_children().size() == 0 &&
		$DesktopWindows/TurtleMemeWEBP/Caption.text != this_is_actually_fine_message
	):
		$DesktopWindows/TurtleMemeWEBP/Caption.text = this_is_actually_fine_message
		$DesktopWindows/TurtleMemeWEBP/Arrows.show()

func _on_screen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	# Confirm that the screen can be interacted with
	if mode == Mode.DISABLED:
		return
	
	if event.is_pressed() && event.is_action("click") && mode == Mode.STATIC:
		_clear_static_circle(_get_mouse_cell_coords())
		ScreenShakeManager.shake_screen(5,5, clearing_all)

func set_static_mode():
	mode = Mode.STATIC

func set_active_mode():
	mode = Mode.ACTIVE
	for icon in $DesktopIcons.get_children():
		icon.disabled = false
	for window in $DesktopWindows.get_children():
		window.disabled = false

func _get_mouse_cell_coords() -> Vector2i:
	var coords:Vector2 = get_global_mouse_position() 
	return Vector2i(
		floor(coords.x/$Static.tile_set.tile_size.x),
		floor(coords.y/$Static.tile_set.tile_size.y),
	)

func clear_all_static():
	clearing_all = true
	
	for i in range(100):
		_clear_static_circle(Vector2i(randi_range(4,67), randi_range(5,28)))
		#ScreenShakeManager.shake_screen(5,5, clearing_all)
		await get_tree().create_timer(0.005).timeout
	
	#clearing_all = true
	#await get_tree().create_timer(0.5).timeout
	
	var static_tiles :Array[Vector2i]= $Static.get_used_cells()
	static_tiles.shuffle()
	
	for i in range(static_tiles.size()): 
		$Static.erase_cell(static_tiles[i])
		
		if i%30 == 0:
			await get_tree().create_timer(0.001).timeout
	

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
func _clear_static_circle(origin:Vector2i):
	
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
	
	if clearing_all:
		return
	
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


func _on_screen_body_entered(body: Node2D) -> void:
	if body is RunningLetter:
		body.set_can_enter_desktop(true)


func _on_screen_body_exited(body: Node2D) -> void:
	if body is RunningLetter:
		body.set_can_enter_desktop(false)


func _on_hammer_man_exe_icon_double_clicked() -> void:
	$DesktopWindows/HammerManEXE/HammerManGame.open()


func _on_home_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") && mode == Mode.ACTIVE && CursorManager.current_cursor == CursorManager.CURSOR:
		for window in $DesktopWindows.get_children():
			window.hide()


func _on_home_button_mouse_entered() -> void:
	if mode == Mode.ACTIVE && CursorManager.current_cursor == CursorManager.CURSOR:
		$HomeButton.scale = Vector2(1.05, 1.05)


func _on_home_button_mouse_exited() -> void:
	if mode == Mode.ACTIVE && CursorManager.current_cursor == CursorManager.CURSOR:
		$HomeButton.scale = Vector2(1, 1)


func _on_fire_extinguisher_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") && mode == Mode.ACTIVE && CursorManager.current_cursor == CursorManager.CURSOR:
		$DesktopWindows/Antivirus/FireExtinguisher.hide()
		CursorManager.set_mouse_cursor(CursorManager.FIRE_EXTINGUISHER)


func _on_a_collect() -> void:
	a_collected.emit($DesktopWindows/TurtleMemeWEBP/A.global_position)

func _on_hammer_man_exe_close_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		$DesktopWindows/HammerManEXE/HammerManGame.close()


func _on_hammer_man_game_hammer_man_escaped(global_pos: Vector2) -> void:
	hammer_man_escaped.emit(global_pos)

func _on_hammer_man_game_level_changed() -> void:
	hammer_man_level_changed.emit()

func _on_hammer_man_game_s_collected(global_pos:Vector2) -> void:
	s_collected.emit(global_pos)


func _on_scan_button_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if mode == Mode.ACTIVE && event.is_action_pressed("click"):
		$DesktopWindows/Antivirus/SeemsFine.text = "scanning..."
		$DesktopWindows/Antivirus/VirusScanTimer.start()

func _on_virus_scan_timer_timeout() -> void:
	$DesktopWindows/Antivirus/SeemsFine.text = "seems fine idk."

func _on_close_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		$DesktopWindows/Antivirus/SeemsFine.text = ""

func _on_scan_button_button_mouse_entered() -> void:
	if mode == Mode.ACTIVE:
		$DesktopWindows/Antivirus/ScanButtonText.scale = Vector2(1.05, 1.05)

func _on_scan_button_button_mouse_exited() -> void:
	if mode == Mode.ACTIVE:
		$DesktopWindows/Antivirus/ScanButtonText.scale = Vector2(1, 1)
