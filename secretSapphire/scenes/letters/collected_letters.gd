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
	if !Global.sfx_muted: $Sound/JumpNoise.play()
	
	await get_tree().create_timer(0.5).timeout
	
	for sprite in $Sprites.get_children():
		sprite.hide()
	jumping = false
	
	jump_finished.emit()

func collect_s(global_from:Vector2):
	$Sprites/S.show()
	$Sprites/S.global_position = global_from
	var tween = get_tree().create_tween()
	tween.tween_property($Sprites/S, "global_position", $IdleMarkers/S.global_position, 0.5).set_ease(Tween.EASE_OUT)
	await tween.finished
	check_all_letters_collected()

func collect_t_1(global_from:Vector2):
	$Sprites/T1.show()
	$Sprites/T1.global_position = global_from
	var tween = get_tree().create_tween()
	tween.tween_property($Sprites/T1, "global_position", $IdleMarkers/T1.global_position, 1).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	check_all_letters_collected()

func collect_a_1(global_from:Vector2):
	$Sprites/A1.show()
	$Sprites/A1.global_position = global_from
	var tween = get_tree().create_tween()
	tween.tween_property($Sprites/A1, "global_position", $IdleMarkers/A1.global_position, 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	check_all_letters_collected()

func collect_r(global_from:Vector2):
	$Sprites/R.show()
	$Sprites/R.global_position = global_from
	var tween = get_tree().create_tween()
	tween.tween_property($Sprites/R, "global_position", $IdleMarkers/R.global_position, 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	check_all_letters_collected()

func collect_t_2(global_from:Vector2):
	$Sprites/T2.show()
	$Sprites/T2.global_position = global_from
	var tween = get_tree().create_tween()
	tween.tween_property($Sprites/T2, "global_position", $IdleMarkers/T2.global_position, 1).set_ease(Tween.EASE_OUT)
	await tween.finished
	check_all_letters_collected()

func check_all_letters_collected():
	for sprite in $Sprites.get_children():
		if sprite is AnimatedSprite2D && !sprite.visible:
			return
	all_letters_collected.emit()
