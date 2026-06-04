extends CharacterBody2D

var target_scene = preload("res://scenes/target_position.tscn")
var fireball_scene = preload("res://scenes/fireball.tscn")
var corpse_scene = preload("res://scenes/corpse.tscn")

@export_category("Statistics")
@export var SPEED: float;
@export var HP: float;
@export var damage: float;
@export_category("Friendly Nodes")
@export var zone: Area2D;
@export var zone_path: String
@export var player: CharacterBody2D;
@export var player_path: String;
@export_category("Child Nodes")
@export var animated_sprite_2d: AnimatedSprite2D
@export var charge_timer: Timer
@export var agent: NavigationAgent2D 
@export var chase_timer: Timer 
@export var label: Label 
@export var death_timer: Timer 
@export var point_light_2d: PointLight2D 
@export var audio_stream_player_2d: AudioStreamPlayer2D

const err = .5;

var rng = RandomNumberGenerator.new()
var jumps = 1.0;
var shoots = 1.0;

enum States {
	IDLE,
	CHASE,
	SHOOT_D,
	SHOOT_R,
	DEATH,
	PASS
}

var sfx_lib = {
	&"charge" : load("res://assets/sfx/spell.wav"),
	&"shoot" : load("res://assets/sfx/magic1.wav"),
	&"chase" : load("res://assets/sfx/Spell_01.mp3"),
	&"hurt" : load("res://assets/sfx/enemy_hurt.mp3"),
	&"death" : load("res://assets/sfx/enemy_death.mp3")
}

@onready var r_target = target_scene.instantiate()
@onready var l_target = target_scene.instantiate()
@onready var center_target = target_scene.instantiate()
var current_target_position: Area2D;

var active_state: States;
var previous_state: States;

var dying = 0;
var center: Vector2;
var l_corner: Vector2;
var r_corner: Vector2;
var charged: int;
var charging: int;
var chasing: int;
var max_hp: float;
var max_speed: float;


func _ready() -> void:
	
	zone = get_node(zone_path)
	player = get_node(player_path)
	
	if player.skill_tree.is_unlocked("heatsense"):
		point_light_2d.visible = true
	active_state = States.IDLE
	max_hp = HP
	max_speed = SPEED
	label.text = "HP:"+str(HP)
	
	center = Vector2(0,0)
	l_corner = Vector2(-zone.get_child(0).shape.size.x/2, zone.get_child(0).shape.size.y/2)
	r_corner = Vector2(zone.get_child(0).shape.size.x/2, zone.get_child(0).shape.size.y/2)

	center_target.global_position = center
	zone.add_child(center_target)
	
	l_target.global_position = l_corner
	zone.add_child(l_target)
	
	r_target.global_position = r_corner
	zone.add_child(r_target)


func _physics_process(delta: float) -> void:
	
	if active_state == States.DEATH:
		death()
	else:
		if player.position.x < position.x:
			animated_sprite_2d.flip_h = true;
		else:
			animated_sprite_2d.flip_h = false;
		
		if zone.overlaps_body(player):
			track_player()
			match active_state:
				States.IDLE:
					relax()
				States.CHASE:
					chase()
				States.SHOOT_R:
					shoot_r()
				States.SHOOT_D:
					shoot_d()
		else:
			relax()
		
	move_and_slide()

func move_to(position: Vector2):
	var dir = to_local(position).normalized()
	velocity = dir * SPEED

func chase() -> void:
	if chasing:
		agent.target_position = player.position
		var dir = to_local(agent.get_next_path_position()).normalized()
		velocity = dir * SPEED
	else:
		active_state = roll(false)

func shoot_r() -> void:
	if !current_target_position.overlaps_body($".") and charged == 0:
		move_to(current_target_position.global_position)
	elif current_target_position.overlaps_body($".") and !charging and charged == 0:
		velocity = Vector2(0,0)
		charge_timer.start()
		charging = 1;
		animated_sprite_2d.play("CHARGE")
		audio_stream_player_2d.stream = sfx_lib[&"charge"]
		audio_stream_player_2d.play()
	
	if charged>0 and charged<5:
		if global_position.y >= (current_target_position.global_position.y-20*charged+err):
			move_to((current_target_position.global_position - Vector2(0,20*charged)))
		else:
			velocity = Vector2(0,0)
			var waterbolt = fireball_scene.instantiate()
			waterbolt.damage = damage
			waterbolt.type = 1
			waterbolt.caster = 1
			waterbolt.SPEED = 400.0
			waterbolt.ANGLE = (int(!animated_sprite_2d.flip_h)) + 180*(int(animated_sprite_2d.flip_h))
			add_child(waterbolt)
			audio_stream_player_2d.stream = sfx_lib[&"shoot"]
			audio_stream_player_2d.play()
			charged += 1
	elif charged >= 5:
		animated_sprite_2d.play("IDLE")
		charged = 6
	
	if charged == 6:
		charged = 0;
		charging = 0;
		active_state = roll(false)

func shoot_d() -> void:
	if !current_target_position.overlaps_body($"."):
		move_to(current_target_position.global_position)
	elif current_target_position.overlaps_body($".") and !charging:
		velocity = Vector2(0,0)
		charge_timer.start()
		charged = 0;
		charging = 1;
		animated_sprite_2d.play("CHARGE")
		audio_stream_player_2d.stream = sfx_lib[&"charge"]
		audio_stream_player_2d.play()
		
	if charged:
		animated_sprite_2d.play("IDLE")
		charged = 0
		charging = 0
		for i in range(3):
			var waterbolt = fireball_scene.instantiate()
			waterbolt.damage = damage
			waterbolt.type = 1
			waterbolt.caster = 1
			waterbolt.SPEED = 400.0
			waterbolt.ANGLE = (360 - i*15)*(int(!animated_sprite_2d.flip_h)) + (180 + i*15)*(int(animated_sprite_2d.flip_h))
			add_child(waterbolt)
			audio_stream_player_2d.stream = sfx_lib[&"shoot"]
			audio_stream_player_2d.play()
		active_state = roll(false)
		
func relax() -> void:
	if !center_target.overlaps_body($"."):
		move_to(zone.position)
	else:
		velocity = Vector2(0,0)
	
	if zone.overlaps_body(player):
		HP = max_hp
		label.text = "HP:"+str(HP)
		print(HP)
		jumps = 1;
		shoots = 1;
		active_state = roll(false)
		
func death():
	if !center_target.overlaps_body($"."):
		move_to(zone.position)
	elif center_target.overlaps_body($".") and !dying:
		dying = 1;
		velocity = Vector2(0,0)
		animated_sprite_2d.play("DEATH")
		audio_stream_player_2d.stream = sfx_lib[&"death"]
		audio_stream_player_2d.play()
		death_timer.start()
	
func roll(force: bool) -> States:
	var fraction1 = jumps/shoots;
	var fraction2 = shoots/jumps;
	var sum = fraction1+fraction2
	fraction1 = (fraction1/sum)*100

	if rng.randf_range(0, 100) < fraction1 and !force:
		chase_timer.start()
		chasing = 1;
		return States.CHASE
	else:
		if rng.randf_range(0,1) < .5:
			current_target_position = l_target
		else:
			current_target_position = r_target
			
		if rng.randf_range(0,1) < .5:
			return States.SHOOT_D
		else:
			return States.SHOOT_R

func track_player() -> void:
	if Input.is_action_just_pressed("l_action"):
		shoots += 1.0
	if Input.is_action_just_pressed("ui_accept"):
		jumps += 1.0

func hit(damage: float):
	HP -= damage
	label.text = "HP:"+str(HP)
	audio_stream_player_2d.stream = sfx_lib[&"hurt"]
	audio_stream_player_2d.play()
	if HP <= 0:
		label.text = "HP:0"
		active_state = States.DEATH

func _on_charge_timer_timeout() -> void:
	charged = 1;

func _on_chase_timer_timeout() -> void:
	chasing = 0;

func _on_death_timer_timeout() -> void:
	var corpse = corpse_scene.instantiate()
	corpse.global_position = global_position
	get_tree().current_scene.add_child(corpse)
	zone.queue_free()
	queue_free()

func _on_navigation_agent_2d_target_reached() -> void:
	chasing = 0;
	active_state = roll(true)
	
func save() -> Dictionary:
	return {
		"scene" : get_scene_file_path(),
		"HP" : HP,
		"SPEED" : SPEED,
		"damage" : damage,
		"x" : position.x,
		"y" : position.y,
		"zone_path" : zone.get_path(),
		"player_path" : player.get_path()
	}
