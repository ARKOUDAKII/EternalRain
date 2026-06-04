extends Node2D

@export var current_level: Node;
@export var Player: CharacterBody2D

func _ready() -> void:
	
	print_tree()
	
	if !current_level:
		current_level = load("res://scenes/main_menu.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func transition(next_level: String) -> void:
	var new_level = load(next_level).instantiate()
	
	new_level.path = "res://files/save_file_level_1.JSON"
	get_tree().current_scene.add_child(new_level)
	get_tree().current_scene.remove_child(current_level)
	
	current_level = new_level
	
	Player.position = Vector2(0,0)

	print_tree()

func load_player() -> void:
	var player = load("res://scenes/player2_0.tscn").instantiate()
	player.HP = 100.0
	player.SPEED = 150.0
	player.JUMP_SPEED = -400.0
	player.DASH_SPEED = 400.0
	player.MAX_DASH = 1
	player.FIRE_DAMAGE = 10.0
	player.DETECTION_RADIUS = 75.0
	player.name = "Player"
	get_tree().current_scene.add_child(player)
	var camera = Camera2D.new()
	camera.zoom = Vector2(2.5, 2.5)
	player.add_child(camera)
	Player = player
	
