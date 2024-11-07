extends Node2D

# TODO: Each of the letter types in this file are handled as individual variables. It
# might be cleaner to move them all into an array and handle them as a collection. Look
# into whether this is the case, and refactor the code accordingly if it is.

enum LetterType {S, T, A, R, G, M, E}
@export var letter_type:LetterType = LetterType.S

# All of the letter types
var letter_body:RigidBody2D
@onready var s: RigidBody2D = $S
@onready var t: RigidBody2D = $T
@onready var a: RigidBody2D = $A
@onready var r: RigidBody2D = $R
@onready var g: RigidBody2D = $G
@onready var m: RigidBody2D = $M
@onready var e: RigidBody2D = $E

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_letter_body()
	disable_all_letters()
	enable_letter(letter_body)

# set_letter_body sets the value of letter_body to the correct child node
# according to the value of letter_type.
func set_letter_body():
	match letter_type: 
		LetterType.S: letter_body = s
		LetterType.T: letter_body = t
		LetterType.A: letter_body = a
		LetterType.R: letter_body = r
		LetterType.G: letter_body = g
		LetterType.M: letter_body = m
		LetterType.E: letter_body = e
		_: print_debug("unknown letter type: ", letter_type)

# disable_all_letters disables and hides all the types of letters in the node tree.
func disable_all_letters():
	disable_letter(s)
	disable_letter(t)
	disable_letter(a)
	disable_letter(r)
	disable_letter(g)
	disable_letter(m)
	disable_letter(e)

# disable_letter disables and hides the provided letter from the node tree.
func disable_letter(l:RigidBody2D):
	l.get_child(1).disabled = true
	l.hide()

# enable_letter enables and shows the provided letter within the node tree.
func enable_letter(l:RigidBody2D):
	l.get_child(1).disabled = false

# spawn reveals the letter and applies a random force to it
func spawn():
	letter_body.show()
	apply_random_force()

# apply_random_force applies a random force on the letter (in the positive Y
# direction, and in any X direction)
#
# TODO: Make the range values in here configurable.
func apply_random_force():
	var x_force:float = randf_range(-750, 750)
	var y_force:float = randf_range(-750, 0)
	letter_body.apply_impulse(Vector2(x_force,y_force))

# TODO: This is purely for debugging. This function should be removed once it's
# no-longer needed.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debugbutton"): 
		spawn()
		apply_random_force()
