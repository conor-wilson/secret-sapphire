class_name SearchForTheSecretSapphire extends Node2D

signal victory

var active:bool = true

var safe_locked:bool = true
var safe_open:bool = false
var picture_on_wall:bool = true
var victory_achieved:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

func reset():
	$Safe.show()
	$PictureFrame.show()
	safe_locked = true
	picture_on_wall = true
	safe_open = false
	victory_achieved = false
	$Instructions.text = "Find the SECRET SAPPHIRE"

func play():
	show()
	active = true
	if !Global.music_muted: $Music.play()

func stop():
	#hide()
	active = false
	$Music.stop()


var confetti_sprites = [
	preload("uid://swomc08vljwn"),
	preload("uid://b63y66uyrn8fe"),
	preload("uid://bt4pqthh4n4jx"),
	preload("uid://dlajiisqj0uqi"),
	preload("uid://fxpq1xctikxs"),
	preload("uid://be1e2vdtsc3xt"),
	preload("uid://0q022el86grs"),
	preload("uid://cqryu78u3gc04"),
]
const NUM_CONFETTI:int = 128

func release_confetti():
	
	if !Global.sfx_muted: $SFX/ConfettiHorn.play()
	
	var screen_width = get_viewport_rect().size.x
	
	for i in range(NUM_CONFETTI):
		var sprite:Sprite2D = Sprite2D.new()
		sprite.texture = confetti_sprites[randi_range(0, len(confetti_sprites)-1)]
		
		# TODO: Also randomise scale?
		sprite.position = Vector2(randf_range(0, screen_width), -64)
		sprite.scale = Vector2.ONE*randf_range(0.75, 1.25)
		
		add_child(sprite)
		
		var tween = create_tween()
		var velocity:Vector2 = Vector2(randf_range(-64, 64), randf_range(128, 640))
		tween.tween_property(sprite, "position", sprite.position + velocity, 2.0)
		tween.parallel().tween_property(sprite, "modulate:a", 0, 1.0).set_delay(1.0)

func _on_safe_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_released("click"):
		if safe_locked:
			$SFX/SafeKnock.pitch_scale = randf_range(0.9, 1.1)
			if !Global.sfx_muted: $SFX/SafeKnock.play()
			$Instructions.text = "<SAFE is LOCKED>"
		else:
			if !Global.sfx_muted: $SFX/SafeOpening.play()
			safe_open = true
			$Instructions.text = "<The SAFE opens>"
			$Safe.hide()


func _on_picture_frame_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_released("click"):
		if !Global.sfx_muted: $SFX/PictureFrameCrash.play()
		$PictureFrame.hide()
		picture_on_wall = false


func _on_red_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_pressed("click") && !picture_on_wall && !safe_open:
		if !Global.sfx_muted: $SFX/Button.play()
		safe_locked = false
		$Instructions.text = "<The SAFE makes a CLICK noise>"
		

func _on_sapphire_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !active: return
	if event.is_action_pressed("click") && safe_open && !victory_achieved:
		$Instructions.text = "<You have found the SECRET SAPPHIRE!>"
		victory_achieved = true
		release_confetti()
		print("GAME WON!")
		await get_tree().create_timer(4).timeout
		victory.emit()
