extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	await get_tree().create_timer(randf_range(0, 0.4)).timeout
	
	match randi_range(0,2):
		0: $AnimatedSprite2D.play("fire_0")
		1: $AnimatedSprite2D.play("fire_1")
		2: $AnimatedSprite2D.play("fire_2")
	
	if randi_range(0,1) == 1:
		$AnimatedSprite2D.flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") && CursorManager.current_cursor == CursorManager.FIRE_EXTINGUISHER:
		hide()


func _on_mouse_entered() -> void:
	if Input.is_action_pressed("click") && CursorManager.current_cursor == CursorManager.FIRE_EXTINGUISHER:
		hide()
