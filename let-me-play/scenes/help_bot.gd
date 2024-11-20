extends Area2D

var speed:float = 25
var idle_speed = 25
var idle_markers:Array[Marker2D]

const HELL_BOT_SHEET = preload("res://assets/art/HellBot-Sheet.png")

var target:Marker2D

@onready var blink_length:float = $AnimationPlayer.get_animation("help_bot_idle").length
@onready var shrink_length:float = $AnimationPlayer.get_animation("hell_bot_shrink").length
@onready var grow_length:float = $AnimationPlayer.get_animation("hell_bot_grow").length

#enum State {IDLE, MOVING}
#var state:State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$IdleSprite.show()
	$ShrinkingSprite.hide()
	
	if idle_markers.size() == 0:
		
		var default_marker = Marker2D.new()
		add_child(default_marker)
		
		idle_markers = [default_marker]
	
	#if exit_marker == null:
		#
		#var default_marker = Marker2D.new()
		#add_child(default_marker)
		#
		#exit_marker = default_marker


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#if state == State.IDLE:
	set_idle_movement_target()
	#if state == State.MOVING:
		#_check_destination_arrived()
	
	move(delta)

func set_idle_movement_target():
	if target == null || position.distance_to(target.position) <10:
		speed = idle_speed
		target = idle_markers[randi_range(0, idle_markers.size()-1)]

#func _check_destination_arrived():
	#if target == null || position.distance_to(target.position) <5:
		#state = State.IDLE

func move(delta:float):
	
	var direction:Vector2 = (target.position - position).normalized()
	
	position += direction * speed * delta

func set_new_idle_location(target_marker:Marker2D, new_idle_markers:Array[Marker2D], move_speed:float=200, new_idle_speed=idle_speed):
	speed = move_speed
	idle_speed = new_idle_speed
	target = target_marker
	idle_markers = new_idle_markers
	#state = State.MOVING

#
## TODO: This is purely for debugging. This function should be removed once it's
## no-longer needed.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debugbutton"): 
		#start_leaving()


func _on_blink_timer_timeout() -> void:
	$AnimationPlayer.play("help_bot_idle")
	await get_tree().create_timer(blink_length).timeout
	$AnimationPlayer.play("RESET")
	$BlinkTimer.start(randf_range(0.0, 5.0))


func become_evil(): 
	$IdleSprite.show()
	$IdleSprite.texture = HELL_BOT_SHEET

func shrink():
	speed = 0
	$BlinkTimer.stop()
	$IdleSprite.hide()
	$ShrinkingSprite.show()
	$AnimationPlayer.play("hell_bot_shrink")
	await get_tree().create_timer(shrink_length).timeout
	$ShrinkingSprite.hide() # TODO: This is janky. Fix.

func grow():
	speed = 0
	$BlinkTimer.stop()
	$IdleSprite.hide()
	$ShrinkingSprite.show()
	$AnimationPlayer.play("hell_bot_grow")
	await get_tree().create_timer(grow_length).timeout
	_on_blink_timer_timeout()
	$ShrinkingSprite.hide()
	$IdleSprite.show()
	$AnimationPlayer.play("help_bot_idle")
