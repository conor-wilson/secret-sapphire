class_name HammerMan extends CharacterBody2D

var active:bool = false

const SPEED = 200.0
const JUMP_VELOCITY = -300.0


func _physics_process(delta: float) -> void:
	
	if !active:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_accept"):
		
		var break_1:bool = break_blocks_in_zone($HammerZone1)
		var break_2:bool = break_blocks_in_zone($HammerZone2)
		if  break_1 || break_2:
			print("BREAK!")
		
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

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
	
	# Report if a block was broken
	return broke_block
