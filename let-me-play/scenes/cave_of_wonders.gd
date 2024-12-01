extends Node2D

signal secret_received
signal t_2_collected

var talking_about_paper:bool = false
var t_2_revealed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func reveal_t_2():
	$T2.show()
	$T2.set_can_collect(true)
	t_2_revealed = true

func _on_cave_mouth_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") || event.is_action_pressed("right_click"):
		secret_received.emit()


func _on_t_2_collect() -> void:
	t_2_collected.emit()
