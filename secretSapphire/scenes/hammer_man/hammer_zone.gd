extends Area2D


func break_blocks() -> bool: 
	
	var broke_block:bool = false
	
	# Check to see if the zone overlaps with any breakable blocks
	for body in get_overlapping_bodies():
		
		if body.is_in_group("BreakableBlocks"):
			
			# Break any breakable tile cells
			if body is TileMapLayer:
				for cell_coords in body.get_used_cells():
					if point_is_in_hammer_zone(body.to_global(body.map_to_local(cell_coords))):
						body.erase_cell(cell_coords)
						broke_block = true
	
	return broke_block


func kill_enemies() -> bool: 
	
	var killed_enemy:bool = false
	
	# Check to see if zone overlaps with any enemies
	for area in get_overlapping_areas():
		
		# Blob Enemy
		if area is BlobEnemy && area.active:
			area.kill()
			killed_enemy = true
		
		# Help Bot
		if area is HelpBot && HammerManManager.current_environment == HammerManManager.Environments.MENUS:
			area.kill()
			killed_enemy = true
	
	# Report if a block was broken
	return killed_enemy


# point_is_in_hammer_zone returns true if the provided coordinates are within
# the hammer zone.
func point_is_in_hammer_zone(point:Vector2) -> bool:
	
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = point
	params.collide_with_areas = true
	
	# Get array of areas that overlap with the point
	var results = space_state.intersect_point(params)
	
	# Return true if the hammer zone is in the list
	for result in results:
		if result.collider == self:
			return true
	return false
