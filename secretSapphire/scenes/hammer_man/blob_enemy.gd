class_name BlobEnemy extends Area2D

signal hit

@export var direction:Vector2 = Vector2.LEFT
@export var speed:float = 1

var active:bool = true 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func kill():
	active = false
	hide()

func respawn():
	active = true
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		position += direction*speed

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

func _on_body_entered(body: Node2D) -> void:
	if active && body is HammerMan && HammerManManager.current_environment == HammerManManager.Environments.GAME:
		hit.emit()
