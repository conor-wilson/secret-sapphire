extends Node

var hammer_man:HammerMan

var hammer_man_game:HammerManGame
var desktop:Desktop
var menus:Menus

enum Environments {GAME, DESKTOP, MENUS}
var current_environment:Environments = Environments.GAME

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

func _process(_delta: float) -> void:
	hammer_man_reparentable = true

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
		current_environment = Environments.GAME
		hammer_man_reparentable = false
		hammer_man.reparent(hammer_man_game)
		hammer_man.z_index = 0
		_set_hammer_man_game_terrain_collision(true)
		_set_hammer_man_desktop_terrain_collision(false)
		_set_hammer_man_menus_terrain_collision(false)

func move_to_desktop():
	# We have a few extra checks here to attempt to ensure the HammerMan has escaped his game in the intended way. 
	if hammer_man_reparentable && hammer_man_game.is_level_three() && (hammer_man_game.hammer_man_in_escape_zone || desktop.hammer_man_in_escape_zone):
		print("REPARENTING HAMMERMAN TO DESKTOP")
		current_environment = Environments.DESKTOP
		hammer_man_reparentable = false
		hammer_man.reparent(desktop)
		hammer_man.z_index = 1
		_set_hammer_man_game_terrain_collision(true)
		_set_hammer_man_desktop_terrain_collision(true)
		_set_hammer_man_menus_terrain_collision(false)

func move_to_menus():
	if hammer_man_reparentable && desktop.hammer_man_in_escape_zone:
		print("REPARENTING HAMMERMAN TO MENUS")
		current_environment = Environments.MENUS
		hammer_man_reparentable = false
		hammer_man.reparent(menus)
		hammer_man.z_index = 1
		_set_hammer_man_game_terrain_collision(false)
		_set_hammer_man_desktop_terrain_collision(true)
		_set_hammer_man_menus_terrain_collision(true)

# _set_hammer_man_desktop_collision sets HammerMan to be interactable or not
# with the desktop boarder and objects. This allows the HammerMan window to be
# able to move below the desktop boarder
func _set_hammer_man_game_terrain_collision(val:bool):
	hammer_man.set_collision_mask_value(13, val)

# _set_hammer_man_desktop_collision sets HammerMan to be interactable or not
# with the desktop boarder and objects.
func _set_hammer_man_desktop_terrain_collision(val:bool):
	hammer_man.set_collision_mask_value(15, val)
	for child in hammer_man.get_children():
		if child is StaticBody2D:
			child.set_collision_layer_value(16, val)

# _set_hammer_man_desktop_collision sets HammerMan to be interactable or not
# with the menus boarder and objects.
func _set_hammer_man_menus_terrain_collision(val:bool):
	hammer_man.set_collision_mask_value(1, val)

# fix_hammer_man_out_of_bounds resets HammerMan to an in-bound state within his
# game (intended to be called when HammerMan goes out of bounds).
func fix_hammer_man_out_of_bounds():
	self.call_deferred("move_to_game")
	hammer_man_game.start_level(hammer_man_game.current_level)
	ScreenShakeManager.shake_screen(5,5)
