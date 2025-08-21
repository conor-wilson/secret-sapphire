extends Node2D

@export var enemies:Array[BlobEnemy] = []
@export var breakable_block_config:TileMapLayer
@export var level_layers:Array[TileMapLayer] = []

@onready var breakable_blocks: TileMapLayer = $BreakableBlocks

func _ready() -> void:
	reset()

func reset():
	
	for level_layer in level_layers:
		level_layer.enabled = true
	
	
	for enemy in enemies:
		enemy.respawn()
	
	for cell_coords in breakable_block_config.get_used_cells_by_id(0, Vector2i(7,1)):
		$BreakableBlocks.set_cell(cell_coords, 1, Vector2i(7, 1))
	
