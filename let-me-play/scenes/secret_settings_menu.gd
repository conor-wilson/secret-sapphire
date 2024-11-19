extends Node2D

# TODO: Add a bunch of dialogue that explains what's going on...

signal shake_screen(strength:float, fade:float)

func free_help_bot():
	shake_screen.emit(5,5)
	_detatch_element_if_exists("Cage", 1)
	await get_tree().create_timer(2.5).timeout
	$HelpBot.hellify()

# TODO: This is a duplicate of the same function in main_menu.gd. Deduplicate
# this.
func _detatch_element_if_exists(path: NodePath, strength:float=1):
	var element := get_node_or_null(path)
	
	# Check that the element can be detatched
	if element == null: return
	if element is not BreakableElement: return
	if !element.idle:   return
	
	# Detatch element
	element.detatch(strength)


func _on_cage_smash() -> void:
	shake_screen.emit(10,5)
