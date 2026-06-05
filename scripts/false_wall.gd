extends AnimatableBody2D

@export_enum("TOP:1","BOTTOM:2") var type: String

@export_category("Child Nodes")
@export var destruct_timer: Timer 
@export var basic_testing_tiles: AnimatedSprite2D

func _ready() -> void:
	basic_testing_tiles.play("fakewall"+type);

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if body.active_state==6 and body.get_node("equipment_handler").cureq["Equipped"] == "HELM":
		destruct_timer.start()
		basic_testing_tiles.play("destruction")
		collision_layer = 0
		body.get_node("equipment_handler").damage_equipment(20)


func _on_destruct_timer_timeout() -> void:
	queue_free()
