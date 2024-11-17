extends Node2D


var interactable:bool = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_screen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	# Confirm that the screen can be interacted with
	if !interactable:
		return
	
	if event.is_pressed() && event.is_action("click"):
		print("screen has been clicked!")
