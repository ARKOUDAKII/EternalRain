extends RigidBody2D

@export var caster: Caster;
@export var type: Type;
@export var damage: float;
@export var SPEED: float;
@export_range(0,360) var ANGLE: float; 

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

enum Caster {
	Friendly,
	Hostile
}

enum Type {
	Fireball,
	Waterbolt
}

var TypeDict = {
	Type.Fireball: Vector2(9.0, 0.0),
	Type.Waterbolt: Vector2(3.0, 0.0)
}

var SPEED_H: float;
var SPEED_V: float;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if !type:
		type = Type.Fireball
		
	if !caster:
		caster = Caster.Friendly
	
	match type:
		Type.Fireball:
			animated_sprite_2d.play("Fireball")
		Type.Waterbolt:
			animated_sprite_2d.play("Waterball")
		_:
			animated_sprite_2d.play("Fireball")
			
	match caster:
		Caster.Friendly:
			collision_mask = 2
		Caster.Hostile:
			collision_mask = 128
		_:
			collision_mask = 2
			
	var rad = deg_to_rad(ANGLE)
	SPEED_H = SPEED * sin(rad)
	SPEED_V = SPEED * cos(rad)
	
	collision_shape_2d.position = TypeDict[type]
	animated_sprite_2d.rotation = rad
	gravity_scale = 0
	inertia = 0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	apply_central_force(Vector2(SPEED_V, SPEED_H))

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	match caster:
		Caster.Friendly:
			body.hit(damage)
		Caster.Hostile:
			body.player_hit(damage)
		_:
			body.hit(damage)
	queue_free()
