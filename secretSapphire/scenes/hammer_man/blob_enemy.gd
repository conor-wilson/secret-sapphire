class_name BlobEnemy extends Area2D

signal hit

@export var start_direction:Vector2 = Vector2.LEFT
@export var speed:float = 60

var direction:Vector2 = Vector2.LEFT
var active:bool = true 
var start_position:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position

func kill():
	active = false
	hide()

func respawn():
	active = false
	position = start_position
	direction = start_direction
	await get_tree().process_frame
	await get_tree().process_frame # TODO: Figure out why this only works when we wait 2 frames here instead of just one...
	active = true
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		position += direction*speed*delta

func _on_wall_detection_left_body_entered(body: Node2D) -> void:
	if active:
		direction = Vector2.RIGHT

func _on_wall_detection_right_body_entered(body: Node2D) -> void:
	if active:
		direction = Vector2.LEFT

func _on_floor_detection_left_body_exited(body: Node2D) -> void:
	if active:
		direction = Vector2.RIGHT

func _on_floor_detection_right_body_exited(body: Node2D) -> void:
	if active:
		direction = Vector2.LEFT

#func _on_body_entered(body: Node2D) -> void:
	#if active && body is HammerMan && HammerManManager.current_environment == HammerManManager.Environments.GAME:
		#hit.emit()


func _on_area_entered(area: Area2D) -> void:
	if active && area.is_in_group("HammerManHitBox") && HammerManManager.current_environment == HammerManManager.Environments.GAME:
		hit.emit()
