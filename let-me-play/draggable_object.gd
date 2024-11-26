class_name DraggableObject extends Node2D

signal double_clicked

var disabled:bool = true
var draggable:bool = false
var is_outside_draggable_boundary:bool = false
#var is_inside_droppable = false
#var body_ref
var offset: Vector2
var initial_pos:Vector2
var boundary_exit_pos:Vector2

@export var draggable_boundary: Area2D
@export var draggable_boundary_centre: Marker2D
@export var is_icon:bool = false
@export var openable_window:DraggableObject


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if disabled || CursorManager.current_cursor != CursorManager.CURSOR:
		return
	
	if draggable: 
		initial_pos = global_position
		if Input.is_action_just_pressed("click"):
			
			if !$DoubleClickTimer.is_stopped():
				double_clicked.emit()
			
			offset = get_global_mouse_position() - global_position
			Global.is_dragging = true
			
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			
			$DoubleClickTimer.start()
			
			Global.is_dragging = false
			
			if is_outside_draggable_boundary:
				var drop_destination:Vector2 = boundary_exit_pos + boundary_exit_pos.direction_to(draggable_boundary_centre.global_position)*32
				var tween = get_tree().create_tween()
				tween.tween_property(self, "global_position", drop_destination, 0.2).set_ease(Tween.EASE_OUT)
			# TODO: Have a look at this and see if we can apply it to the HellBot's movements
			#var tween = get_tree().create_tween()
			#if is_inside_dropable:
				#tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
			#else is_inside_dropable:
				#tween.tween_property(self, "global_position", initial_pos, 0.2).set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	
	if disabled || CursorManager.current_cursor != CursorManager.CURSOR:
		return
	
	if not Global.is_dragging:
		draggable = true
		
		if is_icon:
			scale = Vector2(1.05, 1.05)

func _on_mouse_exited() -> void:
	
	if disabled:
		return
	
	if not Global.is_dragging:
		draggable = false
		if is_icon:
			scale = Vector2(1,1)

func _on_area_exited(area: Area2D) -> void:
	if area == draggable_boundary:
		print("Left the boundary!")
		is_outside_draggable_boundary = true
		boundary_exit_pos = global_position

func _on_area_entered(area: Area2D) -> void:
	if area == draggable_boundary:
		print("Back inside the boundary!")
		is_outside_draggable_boundary = false

#func _input(event: InputEvent) -> void:
	#if event.:
		#$HelpBot.show()
		#$HelpBot.grow()
		#await get_tree().create_timer(2.5).timeout
		#$HelpBot.start_leaving()

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body.is_in_group("dropable"):
		#is_inside_dropable = true
		#body.modulate = Color(Color.REBECCA_PURPLE)
		#body_ref = body

#func _on_area_2d_body_exited(body: Node2D) -> void:
	#if body.is_in_group("dropable"):
		#is_inside_dropable = false
		#body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)


func _on_double_clicked() -> void:
	if is_icon && openable_window != null:
		openable_window.global_position = global_position
		openable_window.show()
