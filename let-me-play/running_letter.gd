extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var direction:Vector2 = Vector2.RIGHT
var activated:bool=false

#func _ready() -> void:
	#$AnimatedSprite2D.play("s-running")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		activate()
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
	if activated:
		velocity.x = direction.x * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func activate(): 
	
	if !activated:
		$ChangeDirTimer.start(randf_range(0.1, 1))
		$JumpTimer.start(randf_range(0.1, 1))
		activated = true
		_set_animation()

func _on_change_dir_timer_timeout() -> void:
	if is_on_floor():
		direction = direction*(-1)
	$ChangeDirTimer.start(randf_range(0.1, 1))
	_set_animation()

func _on_jump_timer_timeout() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	$JumpTimer.start(randf_range(0.1, 3))

func _set_animation():
	if direction == Vector2.RIGHT:
		$AnimatedSprite2D.play("s-running_right")
	else:
		$AnimatedSprite2D.play("s-running_left")
	
