extends StaticBody2D

@export_enum ("Heart") var Pickup: String
@export var effect:int

@onready var pickupsprite: AnimatedSprite2D = $PickupSprite
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	pass#pickupsprite.play(Pickup)

func _on_hitbox_body_entered(body: CharacterBody2D) -> void:
	if body.pick_up($"."):
		queue_free()
