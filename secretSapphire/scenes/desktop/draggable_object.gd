class_name DraggableObject extends Node2D

@export var is_draggable:bool = true

@export var min_global_x:float = 176  # The minimum global x position
@export var max_global_x:float = 1040 # The maximum global x position
@export var min_global_y:float = 112  # The minimum global y position
@export var max_global_y:float = 400  # The maximum global y position

var unteathered:bool = false

signal double_clicked

var disabled:bool = true
var mouse_hover:bool = false

var offset: Vector2

# Indicates if the object is an icon that can open a window.
@export var is_icon:bool = false

# The window that the object will open (if it is an icon) when double clicked.
@export var openable_window:DraggableObject

# The offset that is given to the object when it is "openned". This can be
# applied in positive and negative x/y directions depending on where the object
# is openned from relative to the maximum global x and y values.
@export var open_position_offset:Vector2 = Vector2(128+16, 64)

# The minimum whitespace that is left between the edge of the object and the
# desktop boarder when it is "opened".
@export var min_open_boarder_whitespace:float = 16

# The close button (if it is a window)
@export var close_button:Area2D

func _ready() -> void:
	if !is_icon && close_button != null:
		close_button.input_event.connect(_on_close_input_event)
	else:
		set_z_index(-1)

func open(pos:Vector2) -> void: 
	
	# Derrive the max and min values of the new position
	var new_pos_max_x:float = pos.x + open_position_offset.x
	var new_pos_min_x:float = pos.x - open_position_offset.x
	var new_pos_max_y:float = pos.y + open_position_offset.y
	var new_pos_min_y:float = pos.y - open_position_offset.y
	
	# Determine which of the new position values to use
	var new_pos:Vector2 
	if   new_pos_max_x > (max_global_x-min_open_boarder_whitespace): new_pos.x = new_pos_min_x
	elif new_pos_min_x < (min_global_x+min_open_boarder_whitespace): new_pos.x = new_pos_max_x
	else: new_pos.x = new_pos_max_x
	if   new_pos_max_y > (max_global_y-min_open_boarder_whitespace): new_pos.y = new_pos_min_y
	elif new_pos_min_y < (min_global_y+min_open_boarder_whitespace): new_pos.y = new_pos_max_y
	else: new_pos.y = new_pos_max_y
	
	# Ensure the new position is within the max/min boundaries (with a 16px offset to make things look a bit nicer)
	if   new_pos.x > (max_global_x-min_open_boarder_whitespace): new_pos.x = (max_global_x-min_open_boarder_whitespace)
	elif new_pos.x < (min_global_x+min_open_boarder_whitespace): new_pos.x = (min_global_x+min_open_boarder_whitespace)
	if   new_pos.y > (max_global_y-min_open_boarder_whitespace): new_pos.y = (max_global_y-min_open_boarder_whitespace)
	elif new_pos.y < (min_global_y+min_open_boarder_whitespace): new_pos.y = (min_global_y+min_open_boarder_whitespace)
	
	# Move to new position and open the object
	global_position = new_pos
	
	# Open the object and activate its children
	show()
	for child in get_children():
		if child is TileMapLayer:
			child.enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if disabled || CursorManager.current_cursor != CursorManager.CURSOR:
		return
	
	if CursorManager.current_dragging_object == self && is_draggable:
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
	
	if !unteathered:
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
		|| CursorManager.current_hovering_object != null
	):
		return
	
	mouse_hover = true
	CursorManager.current_hovering_object = self
	if is_icon:
		set_z_index(0)
		scale = Vector2(1.05, 1.05)

# _resolve_no_hover checks to see if the DraggableObject can be considered
# no-longer hovered, and applies any required changes based on the outcome of
# that check.
func _resolve_no_hover():

	if disabled:
		return
	
	mouse_hover = false
	CursorManager.current_hovering_object = null
	if is_icon:
		set_z_index(-1)
		scale = Vector2(1,1)

func _on_double_clicked() -> void:
	if is_icon && openable_window != null && CursorManager.last_dragging_object == self:
		
		openable_window.open(global_position)

func _on_close_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !disabled && !is_icon && event.is_action_pressed("click") && !event.is_action_pressed("pan") && CursorManager.current_cursor == CursorManager.CURSOR:
		close()
	
func close():
	hide()
	for child in get_children():
		if child is TileMapLayer:
			child.enabled = false
