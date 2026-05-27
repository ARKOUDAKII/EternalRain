extends AnimatedSprite2D

@export var player: CharacterBody2D;
@export var Head: AnimatedSprite2D;

func _physics_process(delta: float) -> void:
	match player.active_state:
		2:
			if player.velocity.x == 0.0:
				play("IDLE")
				Head.offset = Vector2(0, 0)
			else:
				play("WALK")
				Head.offset = Vector2(0, 0)
		3:
			if player.velocity.y < 0:
				play("JUMP")
				Head.offset = Vector2(0, 8)
			else:
				play("CROUCH")
				Head.offset = Vector2(0, 8)
		4:
			play("CROUCH")
			Head.offset = Vector2(0, 8)
		5:
			play("CROUCH")
			Head.offset = Vector2(0, 8)
		6:
			play("DASH")
			Head.offset = Vector2(0, 8)
		_:
			pass
