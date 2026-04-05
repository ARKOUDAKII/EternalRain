extends CharacterBody2D

#INSPECTOR
@export_category("Statistics")
@export var SPEED: int
@export var hp: int
#@export var player: Node2D
@export var DAMAGE = 20
@export_category("Supporting Actors")
@export var ROAM_AREA: Area2D

#FLAGS
var Mode = 1 # 1:SLEEP, 2:ROAM, 3:HUNT)
var Idle_Mode = 1
var iframes_monitor = 0
var dead = 0

#GLOBAL VARIABLES
var ntp: Vector2 #Next Target Position
var ROAM_AREA_RADIUS: int
var SLEEP_AREA: Vector2
var player: CharacterBody2D

#CONSTANTS
const type = "Enemy"

#NODES
@onready var bat: NavigationAgent2D = $NavigationAgent2D
@onready var iFrames: Timer = $iFrames
@onready var Hitbox: Area2D = $HitBox
@onready var DetectBox: Area2D = $DetectBox
@onready var Sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_coooldown_timer: Timer = $DetectionCoooldownTimer

#OBJECTS
var rng = RandomNumberGenerator.new()

### ON START
func _ready() -> void:
	Mode = 2
	ROAM_AREA_RADIUS = ROAM_AREA.get_child(0).shape.radius
	SLEEP_AREA = Vector2(ROAM_AREA.position.x, ROAM_AREA.position.y - ROAM_AREA_RADIUS + 5)
	ntp = polar_cords(ROAM_AREA_RADIUS)


### ON FRAME
func _physics_process(delta: float) -> void:
	if !dead:
		if iframes_monitor:
			Hitbox.monitoring = false
		if Mode == 1: #Sleep
			bat.target_position = SLEEP_AREA
			move_to_target()
		elif Mode == 2: #Roam
			bat.target_position = ntp
			move_to_target()
		elif Mode == 3: #Hunt Player
			bat.target_position = player.global_position
			move_to_target()
		else: #Something Wrong
			pass 

### METHODS

func hurt() -> void:
	$Label.text = "HP:"+str(hp)
	Sprite.modulate = Color(18.892, 18.892, 18.892, 1.0)
	Hitbox.monitoring = false
	iFrames.start()

func damage(dmg: int) -> void:
	iframes_monitor = 1
	hp += -1 * dmg
	if hp <= 0:
		death()
	else:
		hurt()

func death() -> void:
	dead = 1
	$Label.text = ""
	Sprite.play("death")
	$DeathTimer.start()

func move_to_target() -> void:
	var dir = to_local(bat.get_next_path_position()).normalized()
	velocity = dir * SPEED
	move_and_slide()

func polar_cords(R: float) -> Vector2:
	var angle = rng.randf_range(0, 2*PI)
	var r = sqrt(rng.randf_range(0 ,1)) * R
	var x = ROAM_AREA.position.x + r * cos(angle)
	var y = ROAM_AREA.position.y + r * sin(angle)
	return Vector2(x, y)

### SINGALS

## AREA SIGNALS
func _on_detect_box_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		if Mode == 4:
			Sprite.play("default")
		Mode = 3
		player = body

func _on_detect_box_body_exited(body: CharacterBody2D) -> void:
	Mode = Idle_Mode

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		damage(body.DAMAGE)
	elif body is CharacterBody2D:
		if body.dash_en:
			damage(body.DAMAGE)
		else:
			detection_coooldown_timer.start()
			DetectBox.monitoring = false
			Mode = 2


## NAVIGATION SIGNALS
func _on_navigation_agent_2d_target_reached() -> void:
	if Mode == 1:
		Sprite.play("sleeping")
		Mode = 4
	if Mode == 2:
		ntp = polar_cords(ROAM_AREA_RADIUS)

## TIMER SIGNALS
func _on_i_frames_timeout() -> void:
	Sprite.modulate = Color(1, 1, 1, 1)
	Hitbox.monitoring = true
	iframes_monitor = 0

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_mode_switch_timer_timeout() -> void:
	if rng.randf_range(0 ,1) < 0.5:
		Idle_Mode = 2
	else:
		Idle_Mode = 1
	if (Mode == 4 and Idle_Mode == 2):
		Sprite.play("default")
		Mode = Idle_Mode
	elif (Mode == 2) or Mode == 1:
		Mode = Idle_Mode

func _on_detection_coooldown_timer_timeout() -> void:
	DetectBox.monitoring = true
