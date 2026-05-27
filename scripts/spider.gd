extends CharacterBody2D

@export var Zone: Area2D;
@export var HP: float;
@export var SPEED: float;
@export var damage: float;

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var death_timer: Timer = $DeathTimer

var dir: int;
var dead = 1;
var max_speed: float;
var limit: Array;

func _ready() -> void:
	Zone.body_shape_entered.connect(_on_zone_body_shape_entered)
	Zone.body_shape_exited.connect(_on_zone_body_shape_exited)
	label.text = "HP:"+str(HP)
	dir = 1;
	max_speed = SPEED;
	SPEED = 0.5*max_speed
	limit = [Zone.position.x - (Zone.get_child(0).shape.size.x/2), Zone.position.x + (Zone.get_child(0).shape.size.x/2)]
	
func _physics_process(delta: float) -> void:
	
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
	if HP <= 0:
		SPEED = 0;
		dead = 0;
		animated_sprite_2d.play("DEATH")
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
