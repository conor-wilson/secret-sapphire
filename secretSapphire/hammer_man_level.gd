class_name HammerManLevel extends Node2D

@export var enemies:Array[BlobEnemy] = []
@export var breakable_block_config:TileMapLayer
@export var level_layers:Array[TileMapLayer] = []
@export var spawn_point:Marker2D

@onready var breakable_blocks: TileMapLayer = $BreakableBlocks

func _ready() -> void:
	if breakable_block_config == null:
		breakable_block_config = TileMapLayer.new()
	breakable_block_config.enabled = false
	move_child(breakable_blocks, len(get_children())-1)
	breakable_blocks.clear()

# start resets the level, and then starts it
func start() -> void:
	
	# Move HammerMan to the start position
	HammerManManager.hammer_man.respawn(spawn_point.position)
	await get_tree().process_frame # Ensure that we wait for the movement to actually take place
	
	# Enable the level's layers
	for level_layer in level_layers:
		level_layer.enabled = true
	
	# Reset all the enemies
	for enemy in enemies:
		enemy.respawn()
	
	# Reset the breakable blocks layer
	for cell_coords in breakable_block_config.get_used_cells_by_id(0, Vector2i(7,1)):
		breakable_blocks.set_cell(cell_coords, 0, Vector2i(7, 1))
	breakable_blocks.enabled = true
	
	show()

# disable disables the level
func disable() -> void:
	
	#TODO: Disable the doors? 
	
	# Disable all the level's layers
	breakable_blocks.enabled = false
	for level in level_layers:
		level.enabled = false
	
	# Kill all the enemies
	for enemy in enemies:
		enemy.kill()
	
	hide()
