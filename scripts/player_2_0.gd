extends CharacterBody2D

@export_category("Statistics")
@export var HP: float;
@export var SPEED: float;
@export var JUMP_SPEED: float;
@export var DASH_SPEED: float;
@export var DETECTION_RADIUS: float;
@export var SPOINTS: int;
@export_category("Friendly Nodes")
@export var Body: AnimatedSprite2D;
@export var Head: AnimatedSprite2D;
@export var attack_handler: Node2D;
@export var equipment_handler: Node2D;
@export var pickup_handler: Node2D;
@export var skill_tree: Node2D;
@export var SKTreeMenu: Node2D;
@export var DetectionBox: Area2D;
@export_category("Timers")
@export var dash_timer: Timer;
@export var dash_cooldown: Timer;
@export var charge_timer: Timer;
@export_category("Labels")
@export var hp_label: Label;
@export var Boon: Label;

enum States {
	PAUSE,
	SKTREE,
	GND,
	AIRBRN,
	CLMB,
	SNEAK,
	DASH
}

enum Moves {
	Normal,
	Ultimate
}

var input_state = {
	"pause": [],
	"selection": [States.SKTREE, States.PAUSE],
	"open_skill_tree": [States.GND, States.SKTREE],
	"directional.x": [States.GND,States.AIRBRN,States.CLMB,States.SNEAK],
	"directional.y": [States.GND,States.AIRBRN,States.CLMB,States.SNEAK],
	"jump": [States.GND, States.CLMB, States.SNEAK],
	"l_action": [States.GND,States.AIRBRN,States.CLMB,States.SNEAK],
	"l_action+down": [States.GND, States.SNEAK],
	"r_action": [States.GND,States.AIRBRN,States.CLMB,States.SNEAK],
	"sneak.pressed": [States.GND],
	"sneak.released": [States.SNEAK, States.CLMB],
	"gravity": [States.GND, States.SNEAK],
	"unequip": [States.PAUSE, States.SKTREE] #MUST'NT HAVE THESE!
}

var max_speed: float;
var active_state: States;
var prev_state: States;
var max_detect_radius: float;
var detection_shape: Shape2D;

var stmenu = 1;
var dead = 0;

var dash_counter = 1;

func _ready() -> void:
	update_label()
	active_state = States.GND
	active_state = States.GND
	max_speed = SPEED
	max_detect_radius = DETECTION_RADIUS
	detection_shape = DetectionBox.get_child(0).shape
	detection_shape.radius = DETECTION_RADIUS
	
func _physics_process(delta: float) -> void:
	print(active_state)
	
	if Input.is_action_just_pressed("pause"):
		attempt_pause();

	check_gravity()
	attempt_h_mvmt(Input.get_axis("ui_left","ui_right"))	

	match active_state:
		States.DASH:
			dash()
		States.AIRBRN:
			airbrn(delta)
		States.CLMB:
			climb(Input.get_axis("ui_up", "ui_down"))
		_:
			pass
		
	if Input.is_action_just_pressed("selection"):
		if input_state["selection"].has(active_state):
			#Execute Selection Logic Here
			pass
	if Input.is_action_just_pressed("open_skill_tree"):
		if input_state["open_skill_tree"].has(active_state):
			sktreemenu()
	if Input.is_action_just_pressed("unequip"):
		if !input_state["unequip"].has(active_state):
			equipment_handler.unequip()
	if Input.is_action_just_pressed("jump"):
		if input_state["jump"].has(active_state):
			attempt_jump()
	if Input.is_action_just_pressed("l_action"):
		if input_state["l_action"].has(active_state):
			charge_timer.start()
	if Input.is_action_just_pressed("ui_down") and !charge_timer.is_stopped():
		if input_state["l_action+down"].has(active_state):
			attempt_fireball(Moves.Ultimate)
	if Input.is_action_just_released("l_action") and !charge_timer.is_stopped():
		if input_state["l_action"].has(active_state):
			attempt_fireball(Moves.Normal)
	if Input.is_action_just_pressed("r_action"):
		if input_state["r_action"].has(active_state):
			attempt_dash();
	if Input.get_action_strength("sneak") > 0.0:
		if input_state["sneak.pressed"].has(active_state):
			attempt_sneak(true)
			if is_on_wall():
				attempt_v_mvmt(true)
	if Input.get_action_strength("sneak") == 0.0:
		if input_state["sneak.released"].has(active_state):
			attempt_sneak(false)
			attempt_v_mvmt(false)
	move_and_slide()

func attempt_pause() -> void:
	pass

func check_gravity() -> void:
	if not is_on_floor():
		if input_state["gravity"].has(active_state):
			prev_state = active_state
			active_state = States.AIRBRN
	
func sktreemenu() -> void:
	if !stmenu:
		prev_state = active_state
		active_state = States.SKTREE
		stmenu=1
		skill_tree.toggle_menu(true)
	else:
		active_state = prev_state
		stmenu=0;
		skill_tree.toggle_menu(false)

func attempt_jump() -> void:
	if active_state == States.GND or active_state == States.SNEAK:
		velocity.y = JUMP_SPEED
	else:
		velocity.y = -JUMP_SPEED

func attempt_h_mvmt(direction: int) -> void:
	if input_state["directional.x"].has(active_state):
		if direction:
			velocity.x = direction * SPEED
			Body.flip_h = (1-direction)/2
			Head.flip_h = (1-direction)/2
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func attempt_v_mvmt(active: bool) -> void:
	if skill_tree.is_unlocked("climb"):
		if active:
			active_state = States.CLMB
		else:
			print("are you here")
			active_state = States.AIRBRN

func attempt_fireball(Move: Moves) -> void:
	match Move:
		Moves.Normal:
			if !skill_tree.is_unlocked("fireball"):
				pass
			elif !skill_tree.is_unlocked("chshoot"):
				attack_handler.fireball(1, 20)
			else:
				print(charge_timer.time_left)
				if charge_timer.time_left > 3.5:
					attack_handler.fireball(1, 20)
				else: 
					var charge_multiplier = 1+((charge_timer.wait_time - charge_timer.time_left)/charge_timer.wait_time)
					attack_handler.fireball(charge_multiplier, 20*charge_multiplier)
		Moves.Ultimate:
			if skill_tree.is_unlocked("detonation"):
				attack_handler.detonate();
		_:
			print("Boom")

func attempt_dash() -> void:
	if skill_tree.is_unlocked("airdash"):
		pass
	elif skill_tree.is_unlocked("dash"):
		if dash_cooldown.is_stopped():
			dash_timer.start()
			dash_cooldown.start()
			prev_state = active_state
			active_state = States.DASH

func attempt_sneak(active: bool) -> void:
	if active:
		SPEED = max_speed*.5
		detection_shape.radius = max_detect_radius*.5
		active_state = States.SNEAK 
	else:
		active_state = States.GND
		SPEED = max_speed
		detection_shape.radius = max_detect_radius

func climb(direction: int):
	if is_on_wall():
		if direction:
			velocity.y = JUMP_SPEED * .25 * -direction
		else:
			velocity.y = 0
	else:
		active_state = States.AIRBRN
	
func dash():
	if skill_tree.is_unlocked("ldash"):
		velocity = Vector2(DASH_SPEED*1.5, 0) * (1-(2*int(Head.flip_h)))
	else:
		velocity = Vector2(DASH_SPEED*1.5, 0) * (1-(2*int(Head.flip_h)))

func airbrn(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		active_state = States.GND

func player_hit(damage: float) -> void:
	HP -= damage;
	if HP <= 0:
		set_physics_process(false)
	update_label()

func update_label() -> void:
	hp_label.text = "HP:"+str(HP)
	Boon.text = "Boon:"+str(equipment_handler.cureq["Boon"])
	
func _on_dash_timer_timeout() -> void:
	active_state = prev_state
