extends AudioStreamPlayer2D

var Library = {
	&"fireball" : load("res://assets/sfx/Spell_02.mp3"),
	&"detonation" : load("res://assets/sfx/Spell_04.mp3")
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
