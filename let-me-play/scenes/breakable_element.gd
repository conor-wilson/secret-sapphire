extends RigidBody2D

signal click
signal smash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0
	connect("body_entered", _on_body_entered)
	connect("input_event", _on_input_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed() && event.is_action("click") && gravity_scale == 0:
		click.emit()

func detatch():
	gravity_scale = 1
	apply_impulse(Vector2(randf_range(-10,10),-200), Vector2(randf_range(-25,25),0))

func _on_body_entered(body: Node) -> void:
	smash.emit()
	queue_free()
