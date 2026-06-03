extends CharacterBody2D

@export_category("Statistics")
@export var hp: float;
@export var damage = 20
@export var speed: float;
@export var dir: Direction;
@export var player:CharacterBody2D;
@export_category("Child Nodes")
@export var label: Label 
@export var point_light_2d: PointLight2D
@export var audio_stream_player_2d: AudioStreamPlayer2D
@export var timer: Timer

var sfx_lib = {
	&"hurt" : load("res://assets/sfx/slime8.wav"),
	&"death" : load("res://assets/sfx/slime9.wav"),
	&"move" : load("res://assets/sfx/slime1.wav")
}

enum Direction {
	Right = 1,
	Left = -1
}

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if player.skill_tree.is_unlocked("heatsense"):
		point_light_2d.visible = true
	if !hp:
		hp = 200;
	if !speed:
		speed = 100.0
		
	label.text = "HP:"+str(hp)

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if rng.randf_range(0, 1) < .005:
		dir = -dir

	velocity.x = dir * speed * 10 * delta
	
	move_and_slide()

func hit(damage: int):
	hp -= damage
	label.text = "HP:"+str(hp)
	audio_stream_player_2d.stream = sfx_lib[&"hurt"]
	audio_stream_player_2d.play()
	if hp <= 0:
		visible = false
		timer.stop()
		timer.autostart = false
		timer.one_shot = true
		timer.wait_time = .56
		timer.start()
		audio_stream_player_2d.stream = sfx_lib[&"death"]
		audio_stream_player_2d.play()

func _on_timer_timeout() -> void:
	audio_stream_player_2d.stream = sfx_lib[&"move"]
	audio_stream_player_2d.play()
	if hp <= 0:
		queue_free()
