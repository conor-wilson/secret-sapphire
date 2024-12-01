extends Node2D

signal jump_finished
signal all_letters_collected

@export var jump_speed:float = 2.5
var jumping:bool = false
var vel_y:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()
	
	## TODO: REMOVE THIS
	#collect_s  (Vector2.ZERO)
	#collect_t_1(Vector2.ZERO)
	#collect_a_1(Vector2.ZERO)
	#collect_r  (Vector2.ZERO)
	#collect_t_2(Vector2.ZERO)

func _process(delta: float) -> void:
	if jumping:
		for sprite in $Sprites.get_children():
			vel_y += 0.98*delta
			sprite.position.y += vel_y


func reset():
	jumping = false
	for sprite in $Sprites.get_children():
		sprite.hide()
		sprite.play("idle")

func jump():
	for sprite in $Sprites.get_children():
		sprite.play("jumping")
	
	await $Sprites/S.frame_changed
	await $Sprites/S.frame_changed
	await $Sprites/S.frame_changed
	jumping = true
	vel_y = -jump_speed
	
	
	await get_tree().create_timer(0.5).timeout
	
	for sprite in $Sprites.get_children():
		sprite.hide()
	jumping = false
	
	jump_finished.emit()

func collect_s(global_from:Vector2):
	$Sprites/S.show()
	$Sprites/S.position = $IdleMarkers/S.position
	check_all_letters_collected()

func collect_t_1(global_from:Vector2):
	$Sprites/T1.show()
	$Sprites/T1.position = $IdleMarkers/T1.position
	check_all_letters_collected()

func collect_a_1(global_from:Vector2):
	$Sprites/A1.show()
	$Sprites/A1.position = $IdleMarkers/A1.position
	check_all_letters_collected()

func collect_r(global_from:Vector2):
	$Sprites/R.show()
	$Sprites/R.position = $IdleMarkers/R.position
	check_all_letters_collected()

func collect_t_2(global_from:Vector2):
	$Sprites/T2.show()
	$Sprites/T2.position = $IdleMarkers/T2.position
	check_all_letters_collected()

func check_all_letters_collected():
	for sprite in $Sprites.get_children():
		if sprite is AnimatedSprite2D && !sprite.visible:
			return
	all_letters_collected.emit()
