extends CharacterBody2D

@export_category("Statistics")
@export var HP: float;
@export var SPEED: float;
@export var damage: float;
@export_category("Friendly Nodes")
@export var Zone: Area2D;
@export var Zone_path: String;
@export var player: CharacterBody2D;
@export var player_path: String;
@export_category("Child Nodes")
@export var animated_sprite_2d: AnimatedSprite2D 
@export var label: Label 
@export var death_timer: Timer 
@export var point_light_2d: PointLight2D 
@export var audio_steam_player_2d: AudioStreamPlayer2D
@export var timer: Timer

var sfx_lib = {
	&"move" : load("res://assets/sfx/Spider Chattering.mp3"),
	&"hurt" : load("res://assets/sfx/spider_hurt.mp3"),
	&"death" : load("res://assets/sfx/spider_death.mp3"),
}

var dir: int;
var dead = 1;
var max_speed: float;
var limit: Array;

func _ready() -> void:
	
	player = get_node(player_path)
	Zone = get_node(Zone_path)
	
	if player.skill_tree.is_unlocked("heatsense"):
		point_light_2d.visible = true
	Zone.body_shape_entered.connect(_on_zone_body_shape_entered)
	Zone.body_shape_exited.connect(_on_zone_body_shape_exited)
	label.text = "HP:"+str(HP)
	dir = 1;
	max_speed = SPEED;
	SPEED = 0.5*max_speed
	limit = [Zone.position.x - (Zone.get_child(0).shape.size.x/2), Zone.position.x + (Zone.get_child(0).shape.size.x/2)]
	
func _physics_process(delta: float) -> void:
	
	if !audio_steam_player_2d.playing:
		audio_steam_player_2d.stream = sfx_lib[&"move"]
		audio_steam_player_2d.play()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if global_position.x < limit[0] or get_wall_normal().x == 1.0:
		dir = 1
	if global_position.x > limit[1] or get_wall_normal().x == -1.0:
		dir = -1
		
	animated_sprite_2d.flip_h = (1-dir)/2
	
	velocity.x = dead * dir * SPEED*50 * delta
	move_and_slide()
	
func hit(damage: float):
	HP -= damage;
	label.text = "HP:"+str(HP)
	audio_steam_player_2d.stream = sfx_lib[&"hurt"]
	audio_steam_player_2d.play()
	if HP <= 0:
		SPEED = 0;
		dead = 0;
		animated_sprite_2d.play("DEATH")
		audio_steam_player_2d.stream = sfx_lib[&"death"]
		audio_steam_player_2d.play()
		death_timer.start()
	
func _on_zone_body_shape_entered(body_rid: RID, body: CharacterBody2D, body_shape_index: int, local_shape_index: int) -> void:
	SPEED = max_speed
	if body.position.x < position.x:
		dir = -1;
	else:
		dir = 1;
		
func _on_zone_body_shape_exited(body_rid: RID, body: CharacterBody2D, body_shape_index: int, local_shape_index: int) -> void:
	SPEED = 0.5 * max_speed

func _on_death_timer_timeout() -> void:
	queue_free()
	
func save() -> Dictionary:
	return {
		"scene" : get_scene_file_path(),
		"HP" : HP,
		"SPEED" : SPEED,
		"damage" : damage,
		"x" : position.x,
		"y" : position.y,
		"Zone_path" : Zone.get_path(),
		"player_path" : player.get_path()
	}
