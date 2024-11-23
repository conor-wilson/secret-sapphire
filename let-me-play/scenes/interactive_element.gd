class_name InteractiveElement extends RigidBody2D

signal click
signal smash

@export var breakable:bool = true
var idle:bool 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0
	idle = true
	connect("body_entered", _on_body_entered)
	connect("input_event", _on_input_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed() && event.is_action("click") && gravity_scale == 0:
		click.emit()

# TODO: Make the individual components in this function configurable
func detatch(strength:float=1):
	gravity_scale = 1
	idle = false
	apply_impulse(Vector2(randf_range(-strength,strength),-20*strength), Vector2(randf_range(-2.5*strength,2.5*strength),0))

# apply_random_force applies a random force on the letter (in the positive Y
# direction, and in any X direction)
#
# TODO: Make the range values in here configurable.
func apply_random_force():
	var x_force:float = randf_range(-750, 750)
	var y_force:float = randf_range(-750, 0)
	apply_impulse(Vector2(x_force,y_force))

func _on_body_entered(body: Node) -> void:
	if !idle && breakable:
		smash.emit()
		queue_free()
