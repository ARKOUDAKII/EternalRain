extends AnimatableBody2D

@export var vine_group: Node

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var desctruct_timer: Timer = $DesctructTimer
@onready var point_light_2d: PointLight2D = $PointLight2D

var burning: float

func force_destruction() -> void:
	desctruct_timer.start()
	point_light_2d.energy = 1
	animated_sprite_2d.play("destruction")
	collision_layer = 0

func _on_hitbox_body_entered(body: RigidBody2D) -> void:
	if body.type == 0 and !burning:
		body.queue_free() 
		burning = 1;
		for vine in vine_group.get_children():
			vine.force_destruction()

func _on_desctruct_timer_timeout() -> void:
	queue_free()
