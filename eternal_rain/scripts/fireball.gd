extends RigidBody2D

var type = "Projectile"
var element = "Fire"

#Stats
@export_category("Statistics")
@export var DIRECTION: int
@export var DAMAGE: int
@export var SPEED: int

#Nodes
@onready var death_timer: Timer = $DeathTimer

## ON START
func _ready() -> void:
	inertia = 0.0
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 1

## ON FRAME
func _process(delta: float) -> void:
	apply_central_force(Vector2(SPEED, 0) * DIRECTION)
	apply_torque(100.0)

### SIGNALS

func _on_body_entered(body: Node) -> void:
	visible = false
	death_timer.start()

func _on_death_timer_timeout() -> void:
	queue_free()
