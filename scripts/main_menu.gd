extends Node2D

@export var player: CharacterBody2D

func _on_start_pressed() -> void:
	new_game()


func _on_settings_pressed() -> void:
	var settings=load("res://scenes/settings_menu.tscn").instantiate()
	settings.caller = "main_menu"
	get_tree().root.add_child(settings)

func new_game() -> void:
	var file = FileAccess.open("res://files/player_file.JSON", FileAccess.WRITE)
	var new = {
		"HP" : 100.0,
		"MAX_SPEED" : 150.0,
		"JUMP_SPEED" : -400.0,
		"DASH_SPEED" : 400.0,
		"MAX_DASH" : 1,
		"FIRE_DAMAGE" : 20.0,
		"SPOINTS" : 0,
		"DETECTION_RADIUS" : 75.0,
		"EQUIPMENT" : "NONE",
		"BOON" : 0.0
	}

	var json = JSON.new()
	var json_string = json.stringify(new)
	file.store_line(json_string)
	
	file = FileAccess.open("res://files/lvl.JSON", FileAccess.WRITE)
	new = {
		"scene" : "res://scenes/entrance.tscn"
	}
	
	json_string = json.stringify(new)
	file.store_line(json_string)
	
	player.skill_tree.reset_skill_tree_JSON()
	
	file.close()

func _on_quit_game_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	var file = FileAccess.open("res://files/lvl.JSON", FileAccess.READ)
	var json_string = file.get_line()
	
	var json = JSON.new()
	
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		pass
	
	var level = json.data
	
	get_tree().change_scene_to_file(level["scene"])
