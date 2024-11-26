extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	await get_tree().create_timer(randf_range(0, 0.4)).timeout
	
	match randi_range(0,2):
		0: play("fire_0")
		1: play("fire_1")
		2: play("fire_2")
	
	if randi_range(0,1) == 1:
		flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
