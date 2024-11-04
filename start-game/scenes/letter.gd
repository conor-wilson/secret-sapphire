extends Node2D

# TODO: Each of the letter types in this file are handled as individual variables. It
# might be cleaner to move them all into an array and handle them as a collection. Look
# into whether this is the case, and refactor the code accordingly if it is.

enum LetterType {S, T, A, R, G, M, E}
@export var letter:LetterType = LetterType.S

# All of the letter types
@onready var s: RigidBody2D = $S
@onready var t: RigidBody2D = $T
@onready var a: RigidBody2D = $A
@onready var r: RigidBody2D = $R
@onready var g: RigidBody2D = $G
@onready var m: RigidBody2D = $M
@onready var e: RigidBody2D = $E

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	disable_all_letters()
	
	match letter: 
		LetterType.S: enable_letter(s)
		LetterType.T: enable_letter(t)
		LetterType.A: enable_letter(a)
		LetterType.R: enable_letter(r)
		LetterType.G: enable_letter(g)
		LetterType.M: enable_letter(m)
		LetterType.E: enable_letter(e)
		_: print_debug("unknown letter type: ", letter)

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
	l.hide()
	l.get_child(1).disabled = true

# enable_letter enables and shows the provided letter within the node tree.
func enable_letter(l:RigidBody2D):
	l.show()
	l.get_child(1).disabled = false
