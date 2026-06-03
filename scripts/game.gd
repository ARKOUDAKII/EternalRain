extends Node2D

@export var player: CharacterBody2D
var scene = preload("res://scenes/respawn.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.dead:
		var instance = scene.instantiate()
		instance.position = player.position + Vector2(-50, -50)
		add_child(instance)
