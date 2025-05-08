extends Camera2D

signal snap(snap_point:Marker2D)
signal returned_home

var free_roam_mode_enabled:bool = false
var zoom_mode_enabled:bool = false

var moving:bool = false
var original_mouse_pos:Vector2 = Vector2.ZERO
var original_pos:Vector2 = global_position

@export var smoothing_speed_free_roam:float = 32
@export var smoothing_speed_stationary:float = 10
@export var snap_distance:float = 64
@export var snap_tolerence:float = 0.1
@export var snap_points:Array[Marker2D] = []
@export var zoom_speed:float = 0.1
@export var zoom_max:float = 3.0
@export var zoom_min:float = 0.1
@export var home_point:Marker2D
@export var centre_point:Marker2D
@export var free_roam_range_x:float = 5000
@export var free_roam_range_y:float = 2500

@export var max_vibration_noise_pitch:float = 1.5
@export var min_vibration_noise_pitch:float = 0.5
@export var vibraction_noise_pitch_variation:float = 0.3


func _ready() -> void:
	ScreenShakeManager.shake.connect(screen_shake_noise)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	apply_screen_shake(delta)
	
	if !moving && free_roam_mode_enabled:
		$CanvasLayer/ReturnHomeInstructions.show()
	else:
		$CanvasLayer/ReturnHomeInstructions.hide()
		
	if Input.is_action_just_pressed("return") && free_roam_mode_enabled && home_point != null:
		global_position = home_point.global_position
		zoom = Vector2(1,1)
		returned_home.emit()
	
	if free_roam_mode_enabled && moving && original_mouse_pos != null:
		
		if centre_point == null:
			print_debug("No centre point provided for free-roam camera")
			return
			
		var new_position:Vector2 = original_pos - get_global_mouse_position() + original_mouse_pos
		
		# Pan the camera on the x-axis if the limit hasn't been reached
		if abs(new_position.x) - abs(centre_point.global_position.x) < free_roam_range_x:
			global_position.x = new_position.x
		else: print("Camera pan limit reached in x-Axis")
		
		# Pan the camera on the y-axis if the limit hasn't been reached
		if abs(new_position.y) - abs(centre_point.global_position.y) < free_roam_range_y:
			global_position.y = new_position.y
		else: print("Camera pan limit reached in y-Axis")
	
	# TODO: This is a very noisy way to check for this. See if we can come up with something better.
	if free_roam_mode_enabled && !moving:
		for snap_point in snap_points: 
			var dist:float = position.distance_to(snap_point.position)
			if dist <= snap_distance && dist > snap_tolerence:
				position = snap_point.position
				snap.emit(snap_point)


func _input(event: InputEvent) -> void:
	
	if !is_current():
		return
	
	if event.is_action_pressed("pan"):
		original_mouse_pos = get_global_mouse_position()
		original_pos = global_position
		moving = true
	elif event.is_action_released("pan"):
		moving = false
	
	if zoom_mode_enabled && event.is_action_pressed("scroll_down") && zoom.x > zoom_min:
		zoom.x -= zoom_speed
		zoom.y -= zoom_speed
	
	if zoom_mode_enabled && event.is_action_pressed("scroll_up") && zoom.x < zoom_max:
		zoom.x += zoom_speed
		zoom.y += zoom_speed

func apply_screen_shake(delta: float):
	
	# No shake required if the strength is below the shake threshold
	if ScreenShakeManager.screen_shake_strength <= 0.001:
		ScreenShakeManager.screen_shake_strength = 0
		return
	
	# Shake the screen
	var new_offset:Vector2 = Vector2(
		randf_range(-ScreenShakeManager.screen_shake_strength, ScreenShakeManager.screen_shake_strength), 
		randf_range(-ScreenShakeManager.screen_shake_strength, ScreenShakeManager.screen_shake_strength),
	)
	offset = new_offset
	
	# Fade the screen shake for the next time
	ScreenShakeManager.screen_shake_strength = lerpf(ScreenShakeManager.screen_shake_strength, 0, ScreenShakeManager.screen_shake_fade*delta)

func screen_shake_noise(strength:float, supress_noise:bool):
	if !Global.sfx_muted:
		#TODO: Make it clearer what's going on below
		$VibrationNoise.pitch_scale = 0.04*(min_vibration_noise_pitch-max_vibration_noise_pitch)*strength+1.2*max_vibration_noise_pitch-0.2*min_vibration_noise_pitch
		$VibrationNoise.pitch_scale = $VibrationNoise.pitch_scale + randf_range(-vibraction_noise_pitch_variation, vibraction_noise_pitch_variation)
		print("Shake Strength:", strength, "Shake Pitch:",$VibrationNoise.pitch_scale)
		
		if !supress_noise: $VibrationNoise.play()

## Roaming Feature Setters

func enable_free_roam():
	free_roam_mode_enabled = true
	position_smoothing_speed = smoothing_speed_free_roam

func disable_free_roam(new_global_position:Vector2 = global_position):
	free_roam_mode_enabled = false
	position_smoothing_speed = smoothing_speed_stationary
	global_position = new_global_position

func enable_zoom():
	zoom_mode_enabled = true

func disable_zoom():
	zoom_mode_enabled = false
	zoom.x = 1
	zoom.y = 1
