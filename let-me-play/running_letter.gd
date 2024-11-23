class_name RunningLetter extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@export var sprite_frames:SpriteFrames
var direction:Vector2 = Vector2.RIGHT
var is_infront_of_desktop:bool = false
var ready_to_exit:bool = false

enum State {IDLE, RUNNING, JUMPING, LANDING}
var state:State = State.IDLE

func _ready() -> void:
	$AnimatedSprite2D.sprite_frames = sprite_frames
	
	if randi_range(0,1):
		direction = -direction

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
	
	_set_velocity()
	move_and_slide()
	_enter_desktop_if_able()
	_set_animation()
	
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

func spawn(new_position:Vector2):
	position = new_position
	show()
	#state = State.JUMPING
	#$AnimatedSprite2D.play("jumping")
	velocity.y = JUMP_VELOCITY/2
	state = State.JUMPING
	$MischiefTimer.start()
	#start_running()
	#_jump()

func start_running(): 
	if state != State.RUNNING:
		$ChangeDirTimer.start(randf_range(0.1, 1))
		$JumpTimer.start(randf_range(0.1, 3))
		state = State.RUNNING

func _on_change_dir_timer_timeout() -> void:
	if is_on_floor():
		direction = direction*(-1)
	$ChangeDirTimer.start(randf_range(0.1, 1))

func _on_jump_timer_timeout() -> void:
	$JumpTimer.start(randf_range(0.1, 3))
	if is_on_floor():
		_jump()

func _jump():
	state = State.JUMPING
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	velocity.y = JUMP_VELOCITY
	

func _set_animation():
	
	if state == State.JUMPING:
		if $AnimatedSprite2D.animation != "jumping":
			print($AnimatedSprite2D.animation)
			$AnimatedSprite2D.play("jumping")
	elif state == State.LANDING:
		$AnimatedSprite2D.play_backwards("jumping")
	elif state == State.RUNNING:
		if direction == Vector2.RIGHT:
			$AnimatedSprite2D.play("running_right")
		else:
			$AnimatedSprite2D.play("running_left")
	else:
		$AnimatedSprite2D.play("idle")

func _set_velocity():
	if state == State.RUNNING || state == State.JUMPING || state == State.LANDING:
		velocity.x = direction.x * SPEED

func _on_left_wall_detector_body_entered(body: Node2D) -> void:
	direction = Vector2.RIGHT

func _on_right_wall_detector_body_entered(body: Node2D) -> void:
	direction = Vector2.LEFT

#func _check_can_enter_desktop():
	#if !is_on_floor() && velocity.y >= -0.01:
		#
		#
		#print("YO")
		#z_index = -100

func _enter_desktop_if_able():
	if !is_on_floor() && velocity.y >= -0.01 && is_infront_of_desktop && ready_to_exit:
		z_index = -1

func set_can_enter_desktop(val:bool):
	is_infront_of_desktop = val

func _on_landing_detector_body_entered(body: Node2D) -> void:
	
	# TODO: This feels a little bit weird. Rethink it.
	if z_index == -1:
		queue_free()
	
	if state == State.JUMPING:
		state = State.LANDING
		await $AnimatedSprite2D.frame_changed
		await $AnimatedSprite2D.frame_changed
		await $AnimatedSprite2D.frame_changed
		start_running()


func _on_mischief_timer_timeout() -> void:
	ready_to_exit = true
