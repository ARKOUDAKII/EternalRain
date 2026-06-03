extends AudioStreamPlayer2D

@export var player: CharacterBody2D

var Library = {
	&"walk" : load(""),
	&"climb" : load("res://assets/sfx/stepdirt_1.mp3"),
	&"jump" : load("res://assets/sfx/SFX_Jump_09.wav"),
	&"dash" : load("res://assets/sfx/swing2.wav"),
}

var force = false;
var active_sound: StringName;

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if !playing:
		force = false;
		set_physics_process(false)

func load_n_play(sound: StringName) -> void:
	if !force:
		stream = Library[sound]
		active_sound = sound
		play()

func force_sound(sound: StringName) -> void:
	force = true
	set_physics_process(true)
	stream = Library[sound]
	active_sound = sound
	play()
	
func get_playing() -> StringName:
	return active_sound;
	
