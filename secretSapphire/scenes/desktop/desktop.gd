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


 # TODO: Rename the below functions and merge them together

func _clear_single_circle(origin:Vector2i, radius:float):
	var max_y:float = ceil(origin.y+radius)
	var min_y:float = floor(origin.y-radius)
	
	for y in range(min_y, max_y):
		var dy:float = origin.y - y
		var dx:float = floor(sqrt(radius*radius - dy*dy))
		
		var x1:float = origin.x - dx
		var x2:float = origin.x + dx
		$Static.erase_cell(Vector2i(x1,y))
		$Static.erase_cell(Vector2i(x2,y))
	
	$Static.erase_cell(Vector2i(origin.x,max_y-1))

func _build_static_in_single_circle(origin:Vector2i, radius:float):
	var max_y:float = ceil(origin.y+radius)
	var min_y:float = floor(origin.y-radius)
	
	for y in range(min_y, max_y):
		var dy:float = origin.y - y
		var dx:float = floor(sqrt(radius*radius - dy*dy))
		
		var x1:float = origin.x - dx
		var x2:float = origin.x + dx
		$Static.set_cell(Vector2i(x1,y), 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
		$Static.set_cell(Vector2i(x2,y), 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))
	
	$Static.set_cell(Vector2i(origin.x,max_y), 1, Vector2i(0,randi_range(0,1)), randi_range(1,8))

# _clear_circle clears a circle of static centred at the provided origin point, 
# and then replaces it again with random static tiles.
#
# TODO: This function and the above matrices are HORRIBLY hard-coded. Figure out
# a way to shorten this down and have no-more duplicated code.
func _clear_static_circle(origin:Vector2i):
	
	# TODO: Use a loop here (or maybe a tween) instead of hard-coding timer awaits before signing
	# off on the above TODO
	
	# Clear static in a circle
	_clear_single_circle(origin, 0.5)
	_clear_single_circle(origin, 1)
	await get_tree().create_timer(0.02).timeout
	_clear_single_circle(origin, 1.5)
	_clear_single_circle(origin, 2)
	await get_tree().create_timer(0.02).timeout
	_clear_single_circle(origin, 2.5)
	_clear_single_circle(origin, 3)
	await get_tree().create_timer(0.02).timeout
	_clear_single_circle(origin, 3.5)
	
	if clearing_all:
		return
	
	# Rebuild the static in the circle
	await get_tree().create_timer(0.2).timeout
	_build_static_in_single_circle(origin, 3.5)
	await get_tree().create_timer(0.02).timeout
	_build_static_in_single_circle(origin, 3)
	await get_tree().create_timer(0.02).timeout
	_build_static_in_single_circle(origin, 2.5)
	await get_tree().create_timer(0.02).timeout
	_build_static_in_single_circle(origin, 2)
	await get_tree().create_timer(0.02).timeout
	_build_static_in_single_circle(origin, 1.5)
	await get_tree().create_timer(0.02).timeout
	_build_static_in_single_circle(origin, 1)
	await get_tree().create_timer(0.02).timeout
	_build_static_in_single_circle(origin, 0.5)
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
