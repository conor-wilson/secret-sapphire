class_name ExpandingCircle extends Area2D

var min_radius:float = 4
var max_radius:float = 48

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



func _ready() -> void:
	print(collision_shape_2d.is_inside_tree())
	collision_shape_2d.shape = CircleShape2D.new()
	collision_shape_2d.shape.radius = min_radius
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("click"):
		#
		#global_position = get_global_mouse_position()
		#
		#var tween = get_tree().create_tween()
		#tween.tween_property($CollisionShape2D.shape, "radius", max_radius, 0.06)
		#await tween.finished
		#await get_tree().create_timer(0.2).timeout
		#tween = get_tree().create_tween()
		#tween.tween_property($CollisionShape2D.shape, "radius", min_radius, 0.14)
		##($CollisionShape2D.shape as CircleShape2D).radius += 16

func spawn():
	global_position = get_global_mouse_position()
	
	print($CollisionShape2D)
	# Expand
	var tween = get_tree().create_tween()
	tween.tween_property($CollisionShape2D.shape, "radius", max_radius, 0.06)
	await tween.finished
	
	# Wait at max radius
	await get_tree().create_timer(0.2).timeout
	
	# Shrink
	tween = get_tree().create_tween()
	tween.tween_property($CollisionShape2D.shape, "radius", min_radius, 0.14)
	await tween.finished
	
	# Delete
	queue_free()
