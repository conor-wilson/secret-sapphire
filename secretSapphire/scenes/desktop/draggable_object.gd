class_name DraggableObject extends Node2D

@export var min_global_x:float = 176 # The minimum global x position
@export var max_global_x:float = 1040 # The maximum global x position
@export var min_global_y:float = 112 # The minimum global y position
@export var max_global_y:float = 400 # The maximum global y position

signal double_clicked

var disabled:bool = true
var mouse_hover:bool = false

var offset: Vector2
var initial_pos:Vector2
var boundary_exit_pos:Vector2

@export var is_icon:bool = false
@export var openable_window:DraggableObject
@export var close_button:Area2D


func _ready() -> void:
	if !is_icon && close_button != null:
		close_button.input_event.connect(_on_close_input_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if disabled || CursorManager.current_cursor != CursorManager.CURSOR:
		return
	
	if CursorManager.current_dragging_object == self:
		follow_cursor()
	
	if mouse_hover:
		
		if Input.is_action_just_pressed("click") && !Input.is_action_pressed("pan"):
			
			if $DoubleClickTimer.is_stopped():
				$DoubleClickTimer.start()
			else:
				double_clicked.emit()
			
			offset = get_global_mouse_position() - global_position
			CursorManager.current_dragging_object = self
		
		# TODO: Have a look at this and see if we can apply it to the HellBot's movements
		#var tween = get_tree().create_tween()
		#if is_inside_dropable:
			#tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
		#else is_inside_dropable:
			#tween.tween_property(self, "global_position", initial_pos, 0.2).set_ease(Tween.EASE_OUT)

func follow_cursor() -> void:
	
	var new_position:Vector2 = get_global_mouse_position() - offset
	
	if new_position.x > max_global_x:
		new_position.x = max_global_x
	if new_position.x < min_global_x:
		new_position.x = min_global_x
	if new_position.y > max_global_y:
		new_position.y = max_global_y
	if new_position.y < min_global_y:
		new_position.y = min_global_y
	
	global_position = new_position

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	_resolve_hover()

func _on_mouse_exited() -> void:
	_resolve_no_hover()

# _resolve_hover checks to see if the DraggableObject can be considered hovered,
# and applies any required changes based on the outcome of that check.
func _resolve_hover():
	if (
		disabled || 
		CursorManager.current_cursor != CursorManager.CURSOR ||
		(CursorManager.current_dragging_object != null && CursorManager.current_dragging_object != self)
	):
		return
	
	mouse_hover = true
	if is_icon:
		scale = Vector2(1.05, 1.05)

# _resolve_no_hover checks to see if the DraggableObject can be considered
# no-longer hovered, and applies any required changes based on the outcome of
# that check.
func _resolve_no_hover():

	if disabled:
		return
	
	mouse_hover = false
	if is_icon:
		scale = Vector2(1,1)

func _on_double_clicked() -> void:
	if is_icon && openable_window != null:
		openable_window.global_position = global_position + Vector2(0, 64)
		openable_window.show()
		for child in openable_window.get_children():
			if child is TileMapLayer:
				child.enabled = true

func _on_close_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !disabled && !is_icon && event.is_action_pressed("click") && !event.is_action_pressed("pan") && CursorManager.current_cursor == CursorManager.CURSOR:
		hide()
		for child in get_children():
			if child is TileMapLayer:
				child.enabled = false
