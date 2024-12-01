extends Area2D

signal collect

@export var can_collect:bool = false

func set_can_collect(can_collect:bool):
	self.can_collect = can_collect

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if can_collect && event.is_action_pressed("click") && CursorManager.current_cursor == CursorManager.CURSOR:
		collect.emit()
		hide()
