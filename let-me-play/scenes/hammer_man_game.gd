extends Node2D

signal hammer_man_escaped(global_pos:Vector2)

@onready var levels:Array[Node2D] = [
	$Levels/Level1,
	$Levels/Level2,
	$Levels/Level3
]

@onready var current_level:Node2D = $Levels/Level1

func _ready() -> void:
	start_level($Levels/Level1)

func open():
	$HammerMan.active = true

func close():
	$HammerMan.active = false

func start_level(desired_level:Node2D):
	
	current_level = desired_level
	
	for level in levels:
		
		# Hide the rest of the levels
		if level != current_level:
			level.hide()
		
		# Disable all other levels' layers
		for layer in level.get_children():
			if layer is TileMapLayer:
				layer.enabled = level == current_level
	
	# Show the desired level and move HammerMan to start position
	desired_level.show()
	$HammerMan.position = $HammerManSpawnPoint.position


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
