extends Node

var hammer_man:HammerMan

var hammer_man_game:HammerManGame
var desktop:Desktop
var menus:Menus

# This var (and its logic below) ensures that we don't end up in any race
# conditions that cause infinite loops (caused due to hammer_man.reparent()
# momentarily freeing hammer_man from the tree). My solution for this is jankey, 
# and is essentially using dead-reckoning, but given that this is a game-jam
# game, I think that's okay. If I was to do this as a long-term project, I would
# completely rework the way that all of this works, but life is too short, and
# my eagerness to move onto more projects is greater than my eagerness to fix
# the invisible issues in this code that players have a 0% chance of
# encountering. 
#
# Basically, if you're a programmer and you're looking at this as an example: 
# don't do it this way. You have time that I did not while I was making this
# game during the jam. Use that time to wire up some signals or something to
# avoid the race condition.
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
		hammer_man.z_index = 0
		get_tree().create_timer(0.01).timeout.connect(_set_hammer_man_reparentable)

func move_to_desktop():
	if hammer_man_reparentable:
		print("REPARENTING HAMMERMAN TO DESKTOP")
		hammer_man_reparentable = false
		hammer_man.reparent(desktop)
		hammer_man.z_index = 1
		get_tree().create_timer(0.01).timeout.connect(_set_hammer_man_reparentable)

func move_to_menus():
	if hammer_man_reparentable:
		print("REPARENTING HAMMERMAN TO MENUS")
		hammer_man_reparentable = false
		hammer_man.reparent(menus)
		hammer_man.z_index = 0
		get_tree().create_timer(0.01).timeout.connect(_set_hammer_man_reparentable)

func _set_hammer_man_reparentable():
	hammer_man_reparentable = true
