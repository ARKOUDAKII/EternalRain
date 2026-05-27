extends CharacterBody2D

@export var HP : float
@export var SPEED = 150.0
@export var DASH_SPEED = 400.0
@export var JUMP_VELOCITY = -400.0
@export var CAST_COST = 10
@export var SPOINTS : int

var dash_en = 1
var iframes_en = 0
var dead = 0
var stmenu = 0
var sneak_en = 0
var climb_en = 0

var dashing = 0
var facing = 1
var climbing = 0

var max_speed: float;
var detection_radius: float;

@onready var equipment_handler: Node2D = $equipment_handler
@onready var pickup_handler: Node2D = $pickup_handler
@onready var attack_handler: Node2D = $attack_handler
@onready var skill_tree: Node2D = $skill_tree

@onready var animated_sprite_2d: AnimatedSprite2D = $body
@onready var Head: AnimatedSprite2D = $Head
@onready var hplabel: Label = $HP
@onready var boon: Label = $Boon
@onready var detection_box: Area2D = $DetectionBox
@onready var shadow_caster: PointLight2D = $ShadowCaster
@onready var illuminator: PointLight2D = $illuminator

@onready var dash_timer: Timer = $Dash_timer
@onready var dash_cooldown: Timer = $Dash_cooldown
@onready var i_frames_timer: Timer = $iFrames_timer
@onready var charge_timer: Timer = $"Charge Timer"

func _ready() -> void:
	hplabel.text = "HP:"+str(HP)
	update_stats()
	update_light()
	max_speed = SPEED
	detection_radius = detection_box.get_child(0).shape.radius

#On frame
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if climbing and is_on_wall():
		velocity.y = -100
	elif climb_en and is_on_wall():
		velocity = Vector2(0 ,0)
	elif (not is_on_floor()):
		velocity += get_gravity() * delta
	get_input()
	move_and_slide() 

#Input function, detects the players input and executes/calls appropriate code/function
func get_input():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		update_animation()

	if Input.is_action_just_pressed("r_action"):
		if !skill_tree.is_unlocked("dash"):
			pass;
		elif dash_en:
			dashing = 1;
			dash_en=0
			dash_timer.start()
			dash_cooldown.start()
			update_animation()
		
	if Input.is_action_just_pressed("l_action"):
		charge_timer.start()
	
	if Input.is_action_just_released("l_action"):
		if !skill_tree.is_unlocked("fireball"):
			pass
		elif !skill_tree.is_unlocked("chshoot"):
			attack_handler.fireball(1, 20)
		else:
			if charge_timer.time_left > 3.5:
				attack_handler.fireball(1, 20)
			else: 
				var charge_multiplier = 1+((charge_timer.wait_time - charge_timer.time_left)/charge_timer.wait_time)
				attack_handler.fireball(charge_multiplier, 20*charge_multiplier)
	
	if Input.is_action_just_pressed("sneak"):
		if skill_tree.is_unlocked("sneak"):
			sneak_en = 1;
			SPEED = max_speed*.5
			detection_box.get_child(0).shape.radius = detection_radius*.5
		
		if skill_tree.is_unlocked("climb") and is_on_wall():
			climb_en = 1;
		
	if Input.is_action_just_released("sneak"):
		sneak_en = 0;
		climb_en = 0;
		SPEED = max_speed
		detection_box.get_child(0).shape.radius = detection_radius
		
	if Input.is_action_just_pressed("ui_up") and climb_en:
		climbing = 1
	
	if Input.is_action_just_released("ui_up"):
		climbing = 0
	
	if Input.is_action_just_pressed("unequip"):
		equipment_handler.unequip()
		
	if Input.is_action_just_pressed("open_skill_tree"):
		if !stmenu:
			stmenu=1
			skill_tree.toggle_menu(true)
		else:
			stmenu=0;
			skill_tree.toggle_menu(false)
		
	var dir = Input.get_axis("ui_left", "ui_right");

	if dir == 1:
		facing = 1
	elif dir == -1:
		facing = -1
		
	if dir or dashing:
		velocity.x = (dir * SPEED * (1-dashing)) + (facing * DASH_SPEED * dashing)
		animated_sprite_2d.flip_h = (facing-1)/2
		Head.flip_h = (facing-1)/2
		update_animation()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		update_animation()

func player_hit(damage: int):
	iframes_en = 1;
	HP -= damage
	update_label()
	update_light()
	if HP <= 0:
		visible = false
		SPEED = 0;
		DASH_SPEED = 0;
		JUMP_VELOCITY = 0;
		dead = 1

func update_stats():
	if skill_tree.is_unlocked("ldash"):
		DASH_SPEED += 200

func update_animation():
	if dashing:
		animated_sprite_2d.play("DASH")
		Head.offset = Vector2(0, 8)
	elif is_on_floor():
		if sneak_en:
			animated_sprite_2d.play("FALL")
			Head.offset = Vector2(0, 8)
		elif velocity.x:
			animated_sprite_2d.play("WALK")
			Head.offset = Vector2(0, 0)
		else:
			animated_sprite_2d.play('IDLE')
			Head.offset = Vector2(0, 0)
	else:
		if velocity.y < 0:
			animated_sprite_2d.play("JUMP")
			Head.offset = Vector2(0, 8)
		else:
			animated_sprite_2d.play("FALL")
			Head.offset = Vector2(0, 8)

func update_label() -> void:
	skill_tree.update_label()
	hplabel.text = "HP:"+str(HP)
	if equipment_handler.cureq["Equipped"] != "NONE":
		boon.visible = true
		boon.text = "Boon:"+str(equipment_handler.cureq["Boon"])
	else:
		boon.visible = false
	
func update_light() -> void:
	var t: float;
	t = ((100-float(HP))/100);
	shadow_caster.texture.fill_to = Vector2(0, 1)*(1-t) + Vector2(0.5, 1)*t  
	illuminator.texture.fill_to = Vector2(0, 1)*(1-t) + Vector2(0.5, 1)*t  

#Timers
func _on_dash_timer_timeout() -> void:
	dashing = 0;

func _on_dash_cooldown_timeout() -> void:
	dash_en = 1;

func _on_i_frames_timer_timeout() -> void:
	iframes_en = 0;
	modulate = Color(1,1,1,1)

func _on_hit_box_body_shape_entered(body_rid: RID, body: CharacterBody2D, body_shape_index: int, local_shape_index: int) -> void:
	if dashing:
		body.hit(attack_handler.dash(body.damage))
	elif !iframes_en:
		iframes_en = 1;
		i_frames_timer.start()
		player_hit(body.damage)
		modulate = Color(1,1,1,.5)
