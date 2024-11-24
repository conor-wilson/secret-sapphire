extends Area2D

signal arrived
signal boom

var speed:float = 25
var idle_speed = 25
var idle_markers:Array[Marker2D]

enum Mode {HELP_BOT, HELL_BOT}
var mode:Mode = Mode.HELP_BOT

var target:Marker2D

enum State {IDLE, MOVING}
var state:State = State.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	show()
	
	if idle_markers.size() == 0:
		
		var default_marker = Marker2D.new()
		add_child(default_marker)
		
		idle_markers = [default_marker]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	set_idle_movement_target()
	
	move(delta)

func set_idle_movement_target():
	if target == null || position.distance_to(target.position) <10:
		
		if state == State.MOVING:
			arrived.emit()
		
		speed = idle_speed
		state = State.IDLE
		target = idle_markers[randi_range(0, idle_markers.size()-1)]

func move(delta:float):
	
	var direction:Vector2 = (target.position - position).normalized()
	
	position += direction * speed * delta
	
	if state == State.MOVING:
		position.y += sin(Time.get_ticks_msec() * 0.005) * 200 * delta

func set_new_idle_location(target_marker:Marker2D, new_idle_markers:Array[Marker2D], move_speed:float=200, new_idle_speed=idle_speed):
	speed = move_speed
	idle_speed = new_idle_speed
	target = target_marker
	idle_markers = new_idle_markers
	state = State.MOVING

#
## TODO: This is purely for debugging. This function should be removed once it's
## no-longer needed.
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debugbutton"): 
		#start_leaving()


func _on_blink_timer_timeout() -> void:
	_blink()
	$BlinkTimer.start(randf_range(0.0, 5.0))

func _blink():
	match mode:
		Mode.HELP_BOT:
			$AnimatedSprite2D.play("help_bot_blink")
		Mode.HELL_BOT:
			$AnimatedSprite2D.play("hell_bot_blink")
		_:
			print_debug("Mode ", mode, " does not have a blink animation")

	await $AnimatedSprite2D.animation_finished
	_become_idle()
	

func _become_idle():
	match mode:
		Mode.HELP_BOT:
			$AnimatedSprite2D.play("help_bot_idle")
		Mode.HELL_BOT:
			$AnimatedSprite2D.play("hell_bot_idle")
		_:
			print_debug("Mode ", mode, " does not have an idle animation")

func become_evil(): 
	mode = Mode.HELL_BOT
	_become_idle()

func shrink():
	$BlinkTimer.stop()
	$AnimatedSprite2D.play("hell_bot_shrink")
	await $AnimatedSprite2D.animation_finished
	hide()

func grow():
	show()
	$BlinkTimer.stop()
	$AnimatedSprite2D.play_backwards("hell_bot_shrink")
	await $AnimatedSprite2D.animation_finished
	_on_blink_timer_timeout()

func shoot(pos:Vector2):
	$Laser.fire(pos)

func explode():
	$BlinkTimer.stop()
	$AnimatedSprite2D.play("hell_bot_explosion")
	
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	await $AnimatedSprite2D.frame_changed
	boom.emit()
	
	await $AnimatedSprite2D.animation_finished
	_on_blink_timer_timeout()
