class_name HammerMan extends CharacterBody2D

signal block_break
signal slam_started

var active:bool = true

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var direction:Vector2 = Vector2.RIGHT
var moving:bool = false
var slamming:bool = false

func _physics_process(delta: float) -> void:
	
	if !active:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle Hammer Slam
	if Input.is_action_just_pressed("ui_accept"):
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
	
	set_sprite()
	
	move_and_slide()

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
		block_break.emit()
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
		if area is BlobEnemy && area.active:
			area.kill()
			broke_block = true
	
	# Report if a block was broken
	return broke_block


func _on_slam_started() -> void:
	slamming = true
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	slam_hammer()
	await $AnimatedSprite2D.animation_finished
	slamming = false
