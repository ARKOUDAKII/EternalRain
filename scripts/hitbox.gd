extends Area2D

@export var player: CharacterBody2D;
@export var iframes: Timer;

@onready var Body: PhysicsBody2D;

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if overlaps_body(Body) and iframes.is_stopped():
		player.player_hit(Body.damage)
		iframes.start()

func _on_body_shape_entered(body_rid: RID, body: CharacterBody2D, body_shape_index: int, local_shape_index: int) -> void:
	if player.active_state == 6:
		body.hit(player.attack_handler.dash())
	else:
		player.player_hit(body.damage)
	iframes.start()
	Body = body
	set_physics_process(true)

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	iframes.stop()
	set_physics_process(false)
