extends Area2D

var bodies;
var damage: float;

func _physics_process(delta: float) -> void:
	if has_overlapping_bodies():
		explode()
	else:
		queue_free()
	
func explode() -> void:
	bodies = get_overlapping_bodies()
	for b in bodies:
		b.hit(damage)
	queue_free()
