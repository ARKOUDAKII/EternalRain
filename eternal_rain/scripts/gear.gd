extends RigidBody2D

#CONSTANTS
const type = "Gear"

#NODES
@onready var press_e: Label = $"Press E"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

#OPTIONS
@export_category("Gear Options")
@export_enum("Hat", "Helm") var Type: String
@export var Amount: int
@export var Max: int

#GLOBAL VARIABLES
var contact_body: Node2D

#FLAGS
var pick_up_flag = false

## ONSTART
func _ready() -> void:
	sprite.play(Type)

## ONFRAME
func _process(delta: float) -> void:
	if pick_up_flag and Input.is_action_just_pressed("pick_up"):
		contact_body.equip($".")
		queue_free()

### SIGNALS
func _on_detect_area_body_entered(body: CharacterBody2D) -> void:
	if body.type == "Player":
		contact_body = body
		pick_up_flag = true
		press_e.visible = true

func _on_detect_area_body_exited(body: Node2D) -> void:
	press_e.visible = false
	pick_up_flag = false
