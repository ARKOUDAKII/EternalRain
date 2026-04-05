extends AnimatableBody2D

@export_enum("TOP:1","BOTTOM:2") var type: String

@onready var destruct_timer: Timer = $DestructTimer
@onready var basic_testing_tiles: AnimatedSprite2D = $BasicTestingTiles

func _ready() -> void:
	basic_testing_tiles.play("fakewall"+type);

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if body.dash_en and body.equipped == "Helm":
		destruct_timer.start()
		basic_testing_tiles.play("destruction")
		collision_layer = 0
		body.pwr += -20
		body.update_label()


func _on_destruct_timer_timeout() -> void:
	queue_free()
