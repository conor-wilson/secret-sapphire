class_name HammerMan extends CharacterBody2D

signal slam_started

var active:bool = false

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

const PUSH_FORCE:float = 80.0
var min_push_normal_x:float = 0.95

var direction:Vector2 = Vector2.RIGHT
var moving:bool = false
var slamming:bool = false
var can_jump:bool = false

func _ready() -> void:
	HammerManManager.set_hammer_man_singleton(self)

func _physics_process(delta: float) -> void:
	
	if !active:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	handle_jumpability()
	handle_jump_buffer()

	# Handle jump.
	if Input.is_action_just_pressed("up"):
		if can_jump:
			jump()
		else:
			$Timers/JumpBufferTimer.start()
	
	# Handle Hammer Slam
	if Input.is_action_just_pressed("slam"):
		slam_started.emit()
	
	# Get the input direction and handle the movement/deceleration.
	moving = false
	if Input.is_action_pressed("right"):
		set_direction(Vector2.RIGHT)
		moving = true
	if Input.is_action_pressed("left"):
		set_direction(Vector2.LEFT)
		moving = true
	if !moving:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#print(moving)
	
	set_sprite()
	
	move_and_slide()
	
	#push_rigid_bodies()

# handle_jumpability detects whether the player should be able to jump, and adjusts the
# can_jump var accordingly.
func handle_jumpability(): 
	if is_on_floor():
		can_jump = true
		$Timers/CoyoteTimer.stop()
	elif can_jump && $Timers/CoyoteTimer.is_stopped(): 
		$Timers/CoyoteTimer.start()

func jump():
	if !Global.sfx_muted: $Sound/JumpNoise.play()
	can_jump = false
	$Timers/CoyoteTimer.stop()
	$Timers/JumpBufferTimer.stop()
	velocity.y = JUMP_VELOCITY

func _on_coyote_timer_timeout() -> void:
	can_jump = false

# handle_jump_buffer causes the player to jump if they have just landed on the floor
# during the jump buffer timeout period.
func handle_jump_buffer():
	if not $Timers/JumpBufferTimer.is_stopped() && can_jump:
		jump()

func set_direction(dir:Vector2):
	direction = dir
	velocity.x = direction.x * SPEED

func set_sprite():
	
	if slamming:
		$AnimatedSprite2D.play("slam")
		return
	
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	if moving: 
		$AnimatedSprite2D.play("running")
	else:
		$AnimatedSprite2D.play("idle")

func slam_hammer():
	
	slamming = true
	
	var break_1:bool = false
	var break_2:bool = false
	if direction.x < 0:
		break_1 = break_blocks_in_zone($HammerZoneLeft1)
		break_2 = break_blocks_in_zone($HammerZoneLeft2)
	else:
		break_1 = break_blocks_in_zone($HammerZoneRight1)
		break_2 = break_blocks_in_zone($HammerZoneRight2)
	
	if break_1 || break_2:
		ScreenShakeManager.shake_screen(5,5)
		print("BREAK!")

func break_blocks_in_zone(zone:Area2D) -> bool:
	
	var broke_block:bool = false
	
	# Check to see if the zone overlaps with any breakable blocks
	for body in zone.get_overlapping_bodies():
		if body.is_in_group("BreakableBlocks"):
			
			# Break any breakable tile cells
			if body is TileMapLayer:
				var body_as_tile_map_layer:TileMapLayer = body as TileMapLayer
				var block_cell_coords:Vector2 = body_as_tile_map_layer.to_local(zone.global_position)/16
				body_as_tile_map_layer.erase_cell(block_cell_coords)
				broke_block = true
	
	# Check to see if zone overlaps with any enemies
	for area in zone.get_overlapping_areas():
		
		# Blob Enemy
		if area is BlobEnemy && area.active:
			area.kill()
			broke_block = true
		
		# Help Bot
		if area is HelpBot && HammerManManager.current_environment == HammerManManager.Environments.MENUS:
			area.kill()
			broke_block = true
	
	# Report if a block was broken
	return broke_block

#func push_rigid_bodies():
	#
	## Push any rigid bodies that HammerMan has encountered
	#for i in get_slide_collision_count():
		#var collision:KinematicCollision2D = get_slide_collision(i)
		#var collider = collision.get_collider()
		#if collider is RigidBody2D:
			#
			#var normal_x:float = collision.get_normal().x
			#
			#if abs(normal_x) > min_push_normal_x:
				#
				#var push_direction:Vector2 = Vector2(-normal_x, 0).normalized()
				#
				#print("PUSH DIRECTION: ", push_direction)
				#print("DIRECTION:      ", direction)
				#print("MOVING:         ", moving)
				#
				#if moving && push_direction == direction:
					#print("PUSH!")
					#collider.apply_central_force(push_direction*PUSH_FORCE)
				#else:
					#print("STOP!")
					#collider.linear_damp(push_direction)


func _on_slam_started() -> void:
	slamming = true
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	slam_hammer()
	await $AnimatedSprite2D.animation_finished
	slamming = false
