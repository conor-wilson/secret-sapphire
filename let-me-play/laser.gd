extends Node2D

const maxrange = 5000

var base_width:float = 24
var width_y:float = base_width
var shoot = false

var target:Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$Line2D.width = width_y
	#
	#var mouse_pos = get_local_mouse_position()
	var max_cast_to = target * maxrange
	$RayCast2D.target_position = max_cast_to
	
	if $RayCast2D.is_colliding():
		$Reference.global_position = $RayCast2D.get_collision_point()
		$Line2D.set_point_position(1, $Line2D.to_local($Reference.global_position))
	else:
		$Reference.global_position = $RayCast2D.target_position
		$Line2D.points[1] = $Reference.global_position

func fire(new_target:Vector2):
	
	$LaserNoise.play()
	
	target = $Line2D.to_local(new_target)
	
	width_y = 2
	await get_tree().create_timer(0.01).timeout
	width_y = 4
	await get_tree().create_timer(0.01).timeout
	width_y = 20
	await get_tree().create_timer(0.01).timeout
	width_y = 24
	await get_tree().create_timer(0.05).timeout
	width_y = 20
	await get_tree().create_timer(0.01).timeout
	width_y = 4
	await get_tree().create_timer(0.01).timeout
	width_y = 2
	await get_tree().create_timer(0.01).timeout
	width_y = 0
