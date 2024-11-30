extends Node2D

signal hammer_man_escaped(global_pos:Vector2)
signal level_changed
signal block_break

@onready var levels:Array[Node2D] = [
	$Levels/Level1,
	$Levels/Level2,
	$Levels/Level3,
	$Levels/VictoryScreen
]

@onready var current_level:Node2D = $Levels/Level1

func _ready() -> void:
	start_level($Levels/Level1)

func open():
	$HammerMan.active = true
	start_level($Levels/Level1)

func close():
	$HammerMan.active = false

func start_level(desired_level:Node2D):
	
	current_level = desired_level
	
	for level in levels:
		
		# Hide the rest of the levels
		if level != current_level:
			level.hide()
		
		# Disable all other levels' layers
		for child in level.get_children():
			if child is TileMapLayer:
				child.enabled = level == current_level
			elif child is BlobEnemy:
				if level == current_level:
					child.respawn()
				else:
					child.kill()
	
	# Show the desired level and move HammerMan to start position
	desired_level.show()
	$HammerMan.position = $HammerManSpawnPoint.position
	level_changed.emit()


func _on_escape_zone_body_entered(body: Node2D) -> void:
	if body is HammerMan:
		body.hide()
		body.active = false
		hammer_man_escaped.emit(body.global_position)
		$HammerMan.position = $HammerManSpawnPoint.position


func _on_level_1_door_body_entered(body: Node2D) -> void:
	if body is HammerMan && current_level == $Levels/Level1:
		start_level($Levels/Level2)

func _on_level_2_door_body_entered(body: Node2D) -> void:
	if body is HammerMan && current_level == $Levels/Level2:
		start_level($Levels/Level3)

func _on_level_3_door_body_entered(body: Node2D) -> void:
	if body is HammerMan && current_level == $Levels/Level3:
		start_level($Levels/VictoryScreen)

func _on_level_1_blob_enemy_hit() -> void:
	start_level($Levels/Level1)

func _on_level_2_blob_enemy_hit() -> void:
	start_level($Levels/Level2)

func _on_level_3_blob_enemy_hit() -> void:
	start_level($Levels/Level3)

func _on_hammer_man_block_break() -> void:
	block_break.emit()
