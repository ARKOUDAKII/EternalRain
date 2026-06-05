extends Control

@onready var respawn_btn: Button = $CenterContainer/VBoxContainer/RespawnBtn
@onready var quit_btn: Button = $CenterContainer/VBoxContainer/QuitBtn

func _on_respawn_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
