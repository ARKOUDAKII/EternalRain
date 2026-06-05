extends Node2D

var scene = preload("res://scenes/panel.tscn").instantiate()

func win() -> void:
	var player = get_tree().current_scene.get_node("Player")
	scene.position = player.position
	get_tree().current_scene.add_child(scene)
