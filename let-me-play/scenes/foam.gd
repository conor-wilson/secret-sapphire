extends GPUParticles2D

var following:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if following:
		global_position = get_global_mouse_position() + Vector2(0,4)

func start_following():
	emitting = true
	following = true

func stop_following():
	emitting = false
	following = false
