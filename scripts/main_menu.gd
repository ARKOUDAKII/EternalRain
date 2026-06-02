extends Node2D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_settings_pressed() -> void:
	var settings=load("res://scenes/settings_menu.tscn").instantiate()
	settings.caller = "main_menu"
	get_tree().root.add_child(settings)


func _on_quit_game_pressed() -> void:
	get_tree().quit()
