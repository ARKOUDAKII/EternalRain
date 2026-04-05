extends CharacterBody2D

#Stats
@export_category("Statistics")
@export var HP = 100
@export var DAMAGE = 20
@export var WALK_SPEED = 90
@export var ACCELERATION = 1
@export var MAX_SPEED = 150
@export var JUMP_VELOCITY = 400
@export var DASH_SPEED = 250
@export var DASH_DURATION = 0.35
@export_enum("Slow:1", "Medium:2", "Fast:5", "Super Fast:10") var CHARGE_SPEED: int

#NODES
@onready var boon: ProgressBar = $Camera2D/ProgressBar2
@onready var hp: ProgressBar = $Camera2D/ProgressBar
@onready var control: Control = $Camera2D/Control
@onready var flame_body: AnimatedSprite2D = $FlameBody
@onready var head: AnimatedSprite2D = $Head
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var hit_box: Area2D = $HitBox
@onready var i_frames: Timer = $iFrames
@onready var center: CollisionShape2D = $Center
@onready var camera_2d: Camera2D = $Camera2D
@onready var GAME_OVR: VBoxContainer = $"../GameOverMenu"
@onready var point_light_2d: PointLight2D = $PointLight2D



#CONST
const FIREBALL = preload("res://scenes/fireball.tscn")
const HAT = preload("res://scenes/hat.tscn")
const HELM = preload("res://scenes/helm.tscn")
const type = "Player"

var equipped = "None"

#GLOBAL VARIABLES
var dir: int
var facing = 1
var pwr = 0
var charge
var max_spells = 0
var speed = WALK_SPEED

#FLAGS
var falling = 1
var dash_en = 0
var iframes_monitor = 0
var dead = 0

func _ready() -> void:
	dash_timer.wait_time = DASH_DURATION
	hp.value = HP
	update_light()

func _physics_process(delta: float) -> void:
	if !dead:
		if iframes_monitor:
			hit_box.monitoring = false
		if dash_en:
			dash()
		else:
			get_input()
		gravity(delta)
		move_and_slide()
	
###METHDOS

#MOVEMENT
func get_input() -> void:
	dir = Input.get_axis("ui_left","ui_right")
	if dir != 0 and is_on_floor():
		head.offset = Vector2(0 , 0)
		flame_body.play("walking")
	else:
		head.offset = Vector2(0 , 0)
		flame_body.play("idle")
	
	
	if dir == 0:
		speed = WALK_SPEED
	elif dir == 1:
		if facing == -1:
			speed = WALK_SPEED
		if speed < MAX_SPEED:
			speed += ACCELERATION
		flame_body.flip_h = false
		head.flip_h = false
		facing = 1
	elif dir == -1:
		if facing == 1:
			speed = WALK_SPEED
		if speed < MAX_SPEED:
			speed += ACCELERATION
		flame_body.flip_h = true
		head.flip_h = true
		facing = -1
	velocity.x = dir * speed 
	
	if Input.is_action_just_pressed("r_action"):
		charge = 0
		dash_en = 1
		dash_timer.start()
	
	if Input.is_action_just_pressed("l_action"):
		if equipped == "Hat" and pwr > 0:
			pwr += -1
			var fireball = FIREBALL.instantiate()
			fireball.DIRECTION = facing
			fireball.DAMAGE = DAMAGE
			fireball.SPEED = 200
			fireball.position.x = position.x + 5 * facing
			fireball.position.y = position.y
			add_sibling(fireball)
			update_label()
			
	if Input.is_action_just_pressed("remove_gear"):
		remove_gear()

func gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		if falling:
			head.offset = Vector2(0 ,8)
			flame_body.play("falling")
		else:
			head.offset = Vector2(0 ,8)
			flame_body.play("jumping")
	
	if velocity.y < 0:
		falling = 0
	else:
		falling = 1
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * -1
		head.offset = Vector2(0 , 4)
		flame_body.play("jumping")
		head.offset.y = 4

func dash() -> void:
	velocity.x = DASH_SPEED * facing
	head.offset = Vector2(facing * 4 , 8)
	flame_body.play("dashing")

#INTERACTION

func damage(body) -> void:
	i_frames.start()
	iframes_monitor = 1
	modulate = Color(0.86, 0.86, 0.86, 1.0)
	HP += body.DAMAGE * -1
	hp.value = HP
	update_light()
	if HP <= 0:
		death()

func pick_up(body: StaticBody2D) -> bool:
	if body.Pickup == "Heart":
		if HP == 100:
			pass
			return false
		elif HP+body.effect<=100:
			HP += body.effect
			update_label()
			update_light()
			return true
		elif HP+body.effect>100:
			HP = 100
			update_label()
			update_light()
			return true
	return false

func equip(body: RigidBody2D) -> void:
	remove_gear()
	head.scale = Vector2(0.359, 0.354)
	head.play(body.Type)
	stat_tranform(body.Type, body.Amount, body.Max)
	update_label()
	equipped = body.Type

func remove_gear() -> void:
	if equipped != "None":
		head.scale = Vector2(0.25, 0.247)
		var spawn_position = head.global_position
		var gear = preload("res://scenes/gear.tscn").instantiate()
		gear.position = spawn_position
		gear.Type = equipped
		gear.Amount = pwr
		add_sibling(gear)
		pwr = 0
		boon.value = 0
		equipped = "None"
		head.play(equipped)

#OTHER

func update_light() -> void:
	var t: float;
	t = ((100-float(HP))/100);
	point_light_2d.texture.fill_to = Vector2(0, 1)*(1-t) + Vector2(0.5, 1)*t  

func update_label() -> void:
	hp.value = HP
	if equipped == "Helm":
		boon.value = pwr
	elif equipped == "Hat":
		boon.value = (pwr*100/max_spells)

func force_equip(Type: String, Amount:int, Max:int):
	head.play(Type)
	stat_tranform(Type, Amount, Max)
	equipped = Type

func stat_tranform(modifier: String, amount: int, max: int):
	if modifier == "Helm":
		pwr = amount
		boon.modulate = Color(0.0, 1.0, 0.0, 1.0)
		boon.value = pwr
	elif modifier == "Hat":
		pwr = amount
		max_spells = max
		if max == 0:
			max_spells = amount
		if max_spells == 0:
			max_spells = 1;
		boon.value = (pwr * 100/max_spells)
		boon.modulate = Color(0.0, 0.0, 1.0, 1.0)

func death():
	dead = 1
	var corpse = HELM.instantiate()
	corpse.position = head.global_position
	GAME_OVR.position = position + Vector2(-GAME_OVR.size.x/2, -GAME_OVR.size.y/2)
	add_sibling(corpse)
	visible = false
	collision_layer = 0


###SIGNALS
func _on_dash_timer_timeout() -> void:
	dash_en = 0
	head.offset = Vector2(0 , 0)
	flame_body.play("idle")
	head.offset.y = 0
	dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout() -> void:
	charge += 10 * CHARGE_SPEED
	if charge == 100:
		dash_cooldown_timer.stop()

func _on_hit_box_body_entered(body: CharacterBody2D) -> void:
	if body.type == "Enemy":
		if !(dash_en and equipped=="Helm" and pwr > 0):
			damage(body)
		else:
			pwr += -10
			update_label()

func _on_i_frames_timeout() -> void:
	modulate = Color(1, 1, 1, 1)
	iframes_monitor = 0
	hit_box.monitoring = true
