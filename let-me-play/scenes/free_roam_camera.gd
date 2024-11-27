extends Camera2D

var moving:bool = false
var original_mouse_pos:Vector2 = Vector2.ZERO
var original_pos:Vector2 = global_position


func _process(delta: float) -> void:
	
	if moving && original_mouse_pos != null:
		position = original_pos - get_global_mouse_position() + original_mouse_pos


func _input(event: InputEvent) -> void:
	
	if !is_current() || CursorManager.current_cursor != CursorManager.CURSOR:
		return
	
	if event.is_action_pressed("right_click"):
		print("Starting Dragging")
		original_mouse_pos = get_global_mouse_position()
		original_pos = global_position
		moving = true
	elif event.is_action_released("right_click"):
		print("Stopping Dragging")
		moving = false
