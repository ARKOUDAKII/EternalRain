extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left","ui_right")
	if direction:
		character_body_2d.velocity.x += direction * 400 * delta
	else:
		character_body_2d.velocity.x = move_toward(character_body_2d.velocity.x, 0, 400)
	character_body_2d.move_and_slide()
