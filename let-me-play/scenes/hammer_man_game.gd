extends Node2D

signal hammer_man_escaped(global_pos:Vector2)

func open():
	$HammerMan.active = true

func close():
	$HammerMan.active = false


func _on_escape_zone_body_entered(body: Node2D) -> void:
	if body is HammerMan:
		body.hide()
		body.active = false
		hammer_man_escaped.emit(body.global_position)
		$HammerMan.position = $HammerManSpawnPoint.position
