extends CharacterBody2D

@export var HP: float;
@export var SPEED: float;
@export var damage: float;
@export var ROAM_AREA: Area2D

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var sleep_timer: Timer = $SleepTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detectbox: Area2D = $Detectbox
@onready var label: Label = $Label
@onready var death_timer: Timer = $DeathTimer
@onready var hit_timer: Timer = $HitTimer

enum Mode {
	SLEEP,
	ROAM,
	HUNT,
	DEATH
}

var active_mode: Mode
var sleep_area: Vector2;
var ntp: Vector2;
var roam_radius: float;
var detect_radius: float;
var max_speed: float;
var player:CharacterBody2D
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	detect_radius = detectbox.get_child(0).shape.radius
	roam_radius = ROAM_AREA.get_child(0).shape.radius
	sleep_area = ROAM_AREA.global_position + Vector2(0, -roam_radius);
	ntp = polar_coords(ROAM_AREA.global_position, roam_radius)
	max_speed = SPEED
	label.text = "HP:"+str(HP)

func _process(delta: float) -> void:
	#print("Active Mode: ",active_mode,"\nCurrent ntp: ",ntp)
	match active_mode:
		Mode.SLEEP:
			agent.target_position = sleep_area
			move_to_target()
		Mode.ROAM:
			agent.target_position = ntp;
			move_to_target()
		Mode.HUNT:
			agent.target_position = player.global_position
			move_to_target()
		Mode.DEATH:
			SPEED = 0

func update_animation() -> void:
	match active_mode:
		Mode.SLEEP:
			animated_sprite_2d.play("SLEEP")
		Mode.ROAM:
			animated_sprite_2d.play("IDLE")
		Mode.HUNT:
			animated_sprite_2d.play("IDLE")
		Mode.DEATH:
			animated_sprite_2d.play("DEATH")

func move_to_target() -> void:
	var dir = to_local(agent.get_next_path_position()).normalized()
	velocity = dir * SPEED
	move_and_slide()

func polar_coords(position: Vector2, R: float) -> Vector2:
	var angle = rng.randf_range(0, 2*PI)
	var r = sqrt(rng.randf_range(0 ,1)) * R
	var x = position.x + r * cos(angle)
	var y = position.y + r * sin(angle)
	#print(ROAM_AREA.global_position)
	#print(r*cos(angle), " ", r*sin(angle))
	return Vector2(x, y)

func passive_mode() -> Mode:
	if rng.randf_range(0, 1) < 0.1:
		return Mode.SLEEP
	else:
		SPEED = max_speed/2
		ntp = polar_coords(ROAM_AREA.global_position, roam_radius)
		update_animation()
		return Mode.ROAM
		
func hit(damage: float):
	modulate = Color(3.563, 3.563, 3.563)
	hit_timer.start()
	HP -= damage;
	label.text = "HP:"+str(HP)
	if HP <= 0:
		detectbox.monitoring = false
		active_mode = Mode.DEATH
		update_animation()
		SPEED = 0;
		death_timer.start()

func _on_detectbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if active_mode == Mode.SLEEP:
		detectbox.get_child(0).shape.radius = detect_radius
		agent.navigation_layers = 1
	player = area.get_parent()
	SPEED = max_speed
	active_mode = Mode.HUNT
	update_animation()
	
func _on_detectbox_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	active_mode = passive_mode()
		
func _on_detectbox_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if active_mode == Mode.SLEEP:
		detectbox.get_child(0).shape.radius = detect_radius
		agent.navigation_layers = 1
	player = body
	SPEED = max_speed
	active_mode = Mode.HUNT
	update_animation()

func _on_detectbox_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	active_mode = passive_mode()

func _on_sleep_timer_timeout() -> void:
	detectbox.get_child(0).shape.radius = detect_radius
	agent.navigation_layers = 1
	active_mode = passive_mode()
	update_animation()

func _on_navigation_agent_2d_target_reached() -> void:
	match active_mode:
		Mode.SLEEP:
			SPEED = 0;
			agent.navigation_layers = 0
			update_animation()
			sleep_timer.start()
			detectbox.get_child(0).shape.radius = detect_radius/2
		Mode.ROAM:
			if detectbox.overlaps_body(player):
				active_mode = Mode.HUNT
			else:
				active_mode = passive_mode()
		Mode.HUNT:
			active_mode = Mode.ROAM

func _on_death_timer_timeout() -> void:
	queue_free()

func _on_hit_timer_timeout() -> void:
	modulate = Color(1,1,1)
