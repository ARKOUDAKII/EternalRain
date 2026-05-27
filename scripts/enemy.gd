extends CharacterBody2D

@export var hp: float;
@export var damage = 20
@export var speed: float;
@export var dir: Direction;

@onready var label: Label = $Label

enum Direction {
	Right = 1,
	Left = -1
}

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if !hp:
		hp = 200;
	if !speed:
		speed = 100.0
		
	label.text = "HP:"+str(hp)

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if rng.randf_range(0, 1) < .005:
		dir = -dir

	velocity.x = dir * speed * 10 * delta
	
	move_and_slide()

func hit(damage: int):
	hp -= damage
	label.text = "HP:"+str(hp)
	if hp <= 0:
		queue_free()
