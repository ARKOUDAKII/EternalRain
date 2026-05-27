extends CharacterBody2D

@export var SPEED:float;
@export var hp: float;
@export var damage: float;
@export var ROAM_AREA: Area2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: Area2D = $DetectionArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var detection_cooldown: Timer = $DetectionCooldown
@onready var sleep_cooldown: Timer = $SleepCooldown
@onready var death_timer: Timer = $DeathTimer

var rng_mode: float;
var detect_radius:float;
var roam_radius: float;
var max_speed:float;
var ntp: Vector2;
var sleep_area: Vector2;
var player: CharacterBody2D

var dying: bool;
var hunting: bool;
var sleeping: bool;
var going_to_sleep: bool;

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	dying = false
	sleeping = false;
	going_to_sleep = false;
	hunting = false;
	detect_radius = detection_area.get_child(0).shape.radius
	roam_radius = ROAM_AREA.get_child(0).shape.radius
	sleep_area = ROAM_AREA.global_position + Vector2(0, -roam_radius);
	ntp = polar_coords(ROAM_AREA.global_position, roam_radius)
	max_speed = SPEED
	label.text = "HP:"+str(hp)
	passive_mode()

func _process(delta: float) -> void:
	if sleeping or dying:
		print("nothign")
	elif hunting:
		agent.target_position = player.global_position
		move_to_target()
	elif going_to_sleep:
		agent.target_position = sleep_area
		move_to_target()
	else:
		agent.target_position = ntp
		move_to_target()
	
func passive_mode() -> void:
	hunting = false;
	going_to_sleep = false;
	if rng.randf_range(0, 1) < 0.1:
		going_to_sleep = true;
		SPEED = max_speed*0.3
	else:
		SPEED = max_speed*0.5
		ntp = polar_coords(ROAM_AREA.global_position, roam_radius)
		
func aggro_mode() -> void:
	hunting = true;
	SPEED = max_speed;
	animated_sprite_2d.play("IDLE")
		
func move_to_target() -> void:
	var dir = to_local(agent.get_next_path_position()).normalized()
	velocity = dir * SPEED
	move_and_slide()

func polar_coords(position: Vector2, R: float) -> Vector2:
	var angle = rng.randf_range(0, 2*PI)
	var r = sqrt(rng.randf_range(0 ,1)) * R
	var x = position.x + r * cos(angle)
	var y = position.y + r * sin(angle)
	return Vector2(x, y)


func hit(damage: float) -> void:
	hp -= damage
	label.text = "HP:"+str(hp)
	if hp <=0:
		dying = true
		SPEED = 0
		detection_area.monitoring = false
		animated_sprite_2d.play("DEATH")
		death_timer.start()

func _on_navigation_agent_2d_target_reached() -> void:
	if hunting:
		passive_mode()
		detection_area.monitoring = false
		detection_cooldown.start()
	elif going_to_sleep:
		sleeping = true;
		SPEED = 0;
		animated_sprite_2d.play("SLEEP")
		sleep_cooldown.start()
	else:
		passive_mode()


func _on_detection_area_body_shape_entered(body_rid: RID, body: CharacterBody2D, body_shape_index: int, local_shape_index: int) -> void:
	player = body
	aggro_mode()
	
func _on_detection_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	passive_mode()

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_sleep_cooldown_timeout() -> void:
	sleeping = false
	animated_sprite_2d.play("IDLE")
	passive_mode()

func _on_detection_cooldown_timeout() -> void:
	detection_area.monitoring = true
	if detection_area.overlaps_body(player):
		aggro_mode()
	else:
		passive_mode()
		
