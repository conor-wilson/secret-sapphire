extends Area2D

@export var speed:float = 25
@export var target_markers:Array[Marker2D]


var target:Marker2D
@onready var blink_length:float = $Sprite2D/AnimationPlayer.get_animation("help_bot_idle").length

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	if target_markers.size() == 0:
		
		var default_marker = Marker2D.new()
		add_child(default_marker)
		
		target_markers = [default_marker]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_idle_movement_target()
	move(delta)

func set_idle_movement_target():
	if target == null || position.distance_to(target.position) <10:
		target = target_markers[randi_range(0, target_markers.size()-1)]

func move(delta:float):
	
	var direction:Vector2 = (target.position - position).normalized()
	
	position += direction * speed * delta
#
## TODO: This is purely for debugging. This function should be removed once it's
## no-longer needed.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debugbutton"): 
		#_animate_blink()


func _on_blink_timer_timeout() -> void:
	$Sprite2D/AnimationPlayer.play("help_bot_idle")
	await get_tree().create_timer(blink_length).timeout
	$Sprite2D/AnimationPlayer.play("RESET")
	$BlinkTimer.start(randf_range(0.0, 5.0))
