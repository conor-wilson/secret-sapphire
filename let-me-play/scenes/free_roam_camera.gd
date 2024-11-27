extends Camera2D

var free_roam_mode_enabled:bool = false

var moving:bool = false
var original_mouse_pos:Vector2 = Vector2.ZERO
var original_pos:Vector2 = global_position

@export var smoothing_speed_free_roam:float = 32
@export var smoothing_speed_stationary:float = 10


func _process(delta: float) -> void:
	
	if free_roam_mode_enabled && moving && original_mouse_pos != null:
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

func enable_free_roam():
	free_roam_mode_enabled = true
	position_smoothing_speed = smoothing_speed_free_roam

func disable_free_roam(new_global_position:Vector2 = global_position):
	free_roam_mode_enabled = false
	position_smoothing_speed = smoothing_speed_stationary
	global_position = new_global_position
