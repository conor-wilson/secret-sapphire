extends Area2D

@export var speed:float = 25
@export var idle_markers:Array[Marker2D]
@export var exit_marker:Marker2D

const HELL_BOT_SHEET = preload("res://assets/art/HellBot-Sheet.png")

var target:Marker2D

@onready var blink_length:float = $AnimationPlayer.get_animation("help_bot_idle").length
@onready var shrink_length:float = $AnimationPlayer.get_animation("hell_bot_shrink").length

enum State {IDLE, LEAVING}
var state:State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$IdleSprite.show()
	$ShrinkingSprite.hide()
	
	if idle_markers.size() == 0:
		
		var default_marker = Marker2D.new()
		add_child(default_marker)
		
		idle_markers = [default_marker]
	
	if exit_marker == null:
		
		var default_marker = Marker2D.new()
		add_child(default_marker)
		
		exit_marker = default_marker


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if state == State.IDLE:
		set_idle_movement_target()
	if state == State.LEAVING:
		set_exit_movement_target()
	
	move(delta)

func set_idle_movement_target():
	if target == null || position.distance_to(target.position) <10:
		target = idle_markers[randi_range(0, idle_markers.size()-1)]

func set_exit_movement_target():
	# TODO: Figure out how to make this more of an arc-movement
	target = exit_marker
	if target == null || position.distance_to(target.position) <5:
		shrink()

func move(delta:float):
	
	var direction:Vector2 = (target.position - position).normalized()
	
	position += direction * speed * delta

func start_leaving():
	speed = 200
	state = State.LEAVING
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
