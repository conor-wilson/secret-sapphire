extends Node2D

var draggable:bool = false
var is_outside_draggable_boundary:bool = false
#var is_inside_droppable = false
#var body_ref
var offset: Vector2
var initial_pos:Vector2
var boundary_exit_pos:Vector2

@export var draggable_boundary: Area2D
@export var draggable_boundary_centre: Marker2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if draggable: 
		initial_pos = global_position
		if Input.is_action_just_pressed("click"):
			offset = get_global_mouse_position() - global_position
			Global.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			Global.is_dragging = false
			
			if is_outside_draggable_boundary:
				global_position = boundary_exit_pos + boundary_exit_pos.direction_to(draggable_boundary_centre.global_position)*64
			
			# TODO: Have a look at this and see if we can apply it to the HellBot's movements
			#var tween = get_tree().create_tween()
			#if is_inside_dropable:
				#tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
			#else is_inside_dropable:
				#tween.tween_property(self, "global_position", initial_pos, 0.2).set_ease(Tween.EASE_OUT)


func _on_area_2d_mouse_entered() -> void:
	if not Global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited() -> void:
	if not Global.is_dragging:
		draggable = false
		scale = Vector2(1,1)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area == draggable_boundary:
		print("Left the boundary!")
		is_outside_draggable_boundary = true
		boundary_exit_pos = global_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == draggable_boundary:
		print("Back inside the boundary!")
		is_outside_draggable_boundary = false

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("dropable"):
		#is_inside_dropable = true
		#body.modulate = Color(Color.REBECCA_PURPLE)
		#body_ref = body

#func _on_area_2d_body_exited(body: Node2D) -> void:
	#if body.is_in_group("dropable"):
		#is_inside_dropable = false
		#body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
