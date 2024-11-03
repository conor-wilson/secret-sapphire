extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed() && event.is_action("click") && gravity_scale == 0:
		gravity_scale = 1
