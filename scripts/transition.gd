extends Area2D

@export var level_destination: String
@export var level: Node2D

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	level.transition(level_destination)
