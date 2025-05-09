class_name DraggableObject extends Area2D

@export var is_draggable:bool = true

@export var min_global_x:float = 176  # The minimum global x position
@export var max_global_x:float = 1040 # The maximum global x position
@export var min_global_y:float = 112  # The minimum global y position
@export var max_global_y:float = 400  # The maximum global y position

var unteathered:bool = false

signal double_clicked

var disabled:bool = true
var mouse_hover:bool = false
var mouse_in_draggable_area:bool = false

var offset: Vector2

# Indicates if the object is an icon that can open a window.
@export var is_icon:bool = false

@export var draggable_area:Area2D

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
	if is_icon:
		set_z_index(-2)
	else:
		set_z_index(-1)
	
	if close_button != null:
		close_button.input_event.connect(_on_close_input_event)
	
	if draggable_area == null: 
		draggable_area = self as Area2D
	draggable_area.mouse_entered.connect(_on_draggable_area_mouse_entered)
	draggable_area.mouse_exited.connect(_on_draggable_area_mouse_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if disabled || CursorManager.current_cursor != CursorManager.CURSOR:
		return
	
	var moved:bool = false
	if CursorManager.current_dragging_object == self && is_draggable:
		moved = follow_cursor()
	
	# Reset the double-click system if the object has been moved
	if moved: 
		$FirstClickTimer.stop()
		$SecondClickTimer.stop()
	
	if mouse_hover:
		
		if Input.is_action_just_pressed("click") && !Input.is_action_pressed("pan"):
			
			# Bring the DraggableObject to the top of the draw order
			move_to_top_of_parent()
			
			# Track progress of clicks
			if $FirstClickTimer.is_stopped():
				$FirstClickTimer.start()
			else:
				$SecondClickTimer.start()
			
			# Resolve dragging functionality
			if mouse_in_draggable_area:
				offset = get_global_mouse_position() - global_position
				CursorManager.current_dragging_object = self
		
		# Resolve double click
		if Input.is_action_just_released("click") && !Input.is_action_just_released("pan"):
			if !$SecondClickTimer.is_stopped():
				double_clicked.emit()
		
		# TODO: Have a look at this and see if we can apply it to the HellBot's movements
		#var tween = get_tree().create_tween()
		#if is_inside_dropable:
			#tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
		#else is_inside_dropable:
			#tween.tween_property(self, "global_position", initial_pos, 0.2).set_ease(Tween.EASE_OUT)


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

func follow_cursor() -> bool:
	
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
	
	var moved:bool = global_position.distance_to(new_position) > 1
	
	global_position = new_position
	
	return moved


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if disabled:
		return
	
	# NOTE: We use the input_event signal here instead of the mouse_entered signal because we need
	# to account for when the cursor mouses onto this DraggableObject from another DraggableObject 
	# with a higher draw-order whose collision area overlaps with this DraggableObject.
	if (
		event is InputEventMouseMotion && 
		_should_become_current_hovering_object()
		):
		_start_hovering()

func _on_mouse_exited() -> void:
	if disabled:
		return
	
	stop_hovering()

# _should_become_current_hovering_object returns true if the DraggableObject should become the new
# current hovering object in the CursorManager. This is done using a series of checks that increase
# from broad to intricate, returning at the broadest possible check. 
func _should_become_current_hovering_object() -> bool:
	
	# If the player is holding an object return true.
	if !CursorManager.current_cursor_is(CursorManager.CURSOR):
		return false
	
	# If the cursor is dragging another DraggableObject, return false
	if CursorManager.current_dragging_object != null && CursorManager.current_dragging_object != self:
		return false
	
	# If the cursor isn't hovering over anything, return true
	var current_hovering_object:DraggableObject = CursorManager.current_hovering_object
	if current_hovering_object == null:
		return true
	
	# If the cursor is already hovering over this Draggable object, return false (because we don't
	# need to change anything)
	if current_hovering_object == self:
		return false
	
	# If the z-indexes aren't equal, return true if this DraggableObject is drawn above the
	# currently hovered DraggableObject
	if current_hovering_object.z_index != z_index:
		return current_hovering_object.z_index < z_index
	
	# Icons should always give way to non-icons in the hover order
	if is_icon && !current_hovering_object.is_icon:
		return false
	if !is_icon && current_hovering_object.is_icon:
		return true
	
	# If this DraggableObject and the currently hovered DraggableObject don't have the same parent,
	# we can't resolve the hover, so default to true.
	var parent:Node = get_parent()
	if parent != current_hovering_object.get_parent():
		return true
	
	# If this DraggableObject and the currently hovered DraggableObject do have the same parent,
	# determine which of the two are drawn on top, and return true if that is this DraggableObject.
	var current_hovering_object_index:int = 0
	var self_index:int = 0
	var count:int = 0
	for child in parent.get_children():
		
		if child == self:
			self_index = count
		if child == current_hovering_object:
			current_hovering_object_index = count
		
		count = count + 1
	
	return self_index > current_hovering_object_index

# _start_hovering applies the changes that should occur when the DraggableObject is being hovered
# over by the mouse.
func _start_hovering():
	
	if CursorManager.current_hovering_object != null:
		CursorManager.current_hovering_object.stop_hovering()
	
	mouse_hover = true
	CursorManager.current_hovering_object = self
	
	if is_icon:
		set_z_index(-1)
		scale = Vector2(1.05, 1.05)


# stop_hovering applies the changes that should occur when the DraggableObject is no-longer being
# hovered over by the mouse.
func stop_hovering():
	
	if CursorManager.current_hovering_object == self:
		CursorManager.current_hovering_object = null
	
	mouse_hover = false
	
	if is_icon:
		set_z_index(-2)
		scale = Vector2(1,1)

func move_to_top_of_parent():
	var parent:Node = get_parent()
	reparent(parent.get_parent())
	reparent(parent)

func _on_double_clicked() -> void:
	if is_icon && openable_window != null && CursorManager.last_dragging_object == self:
		
		openable_window.open(global_position)

func _on_close_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (
		!disabled &&
		!is_icon && 
		event.is_action_pressed("click") && 
		!event.is_action_pressed("pan") && 
		CursorManager.current_cursor == CursorManager.CURSOR &&
		CursorManager.current_hovering_object == self
		):
		close()

func close():
	hide()
	for child in get_children():
		if child is TileMapLayer:
			child.enabled = false

func _on_draggable_area_mouse_entered():
	mouse_in_draggable_area = true

func _on_draggable_area_mouse_exited():
	mouse_in_draggable_area = false
