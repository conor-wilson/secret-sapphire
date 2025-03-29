extends Node

var hammer_man:HammerMan

var hammer_man_game:HammerManGame
var desktop:Desktop
var menus:Menus

var hammer_man_reparentable:bool = true

func set_hammer_man_singleton(new_hammer_man:HammerMan):
	if hammer_man == null:
		hammer_man = new_hammer_man
	else:
		print("HammerMan Singleton was attempted to be set when one already exists")

func set_hammer_man_game_singleton(new_hammer_man_game:HammerManGame):
	if hammer_man_game == null:
		hammer_man_game = new_hammer_man_game
	else:
		print("HammerManGame Singleton was attempted to be set when one already exists")

func set_desktop_singleton(new_desktop:Desktop):
	if desktop == null:
		desktop = new_desktop
	else:
		print("Desktop Singleton was attempted to be set when one already exists")

func set_menus_singleton(new_menus:Menus):
	if menus == null:
		menus = new_menus
	else:
		print("Menus Singleton was attempted to be set when one already exists")


func move_to_game():
	if hammer_man_reparentable:
		print("REPARENTING HAMMERMAN TO HAMMERMAN GAME")
		hammer_man_reparentable = false
		hammer_man.reparent(hammer_man_game)
		get_tree().create_timer(0.01).timeout.connect(_set_hammer_man_reparentable)

func move_to_desktop():
	if hammer_man_reparentable:
		print("REPARENTING HAMMERMAN TO DESKTOP")
		hammer_man_reparentable = false
		hammer_man.reparent(desktop)
		get_tree().create_timer(0.01).timeout.connect(_set_hammer_man_reparentable)

func move_to_menus():
	if hammer_man_reparentable:
		print("REPARENTING HAMMERMAN TO MENUS")
		hammer_man_reparentable = false
		hammer_man.reparent(menus)
		get_tree().create_timer(0.01).timeout.connect(_set_hammer_man_reparentable)

func _set_hammer_man_reparentable():
	hammer_man_reparentable = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
