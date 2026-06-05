extends CanvasLayer

@onready var restart_btn = $CenterContainer/VBoxContainer/RestartButton
@onready var settings_btn = $CenterContainer/VBoxContainer/SettingsButton
@onready var main_menu_btn = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_game_btn = $CenterContainer/VBoxContainer/QuitGameButton

func _ready() -> void:
	get_tree().paused = true   #freezes the game
	restart_btn.grab_focus()   
	
func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("pause"):
		_resume_game()
		
func _resume_game() -> void:
	get_tree().paused = false
	queue_free()
	
	
func _set_buttons_focus_mode(mode: Control.FocusMode) -> void:
	restart_btn.focus_mode = mode
	settings_btn.focus_mode = mode
	main_menu_btn.focus_mode = mode
	quit_game_btn.focus_mode = mode
	
	
############Signals#################

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	# kwdikas gia to respawn/reload
	queue_free()

func _on_settings_button_pressed() -> void:
	var settings_scene = preload("res://scenes/settings_menu.tscn").instantiate()
	settings_scene.caller = "pause_menu"
	$CenterContainer.hide()
	_set_buttons_focus_mode(Control.FOCUS_NONE)
	
	settings_scene.tree_exited.connect(func():
		$CenterContainer.show() # Επανεμφανίζουμε το Pause Menu
		_set_buttons_focus_mode(Control.FOCUS_ALL) # Επαναφέρουμε το focus
		restart_btn.grab_focus() # Ξαναδίνουμε focus στο πρώτο κουμπί
	)
	
	add_child(settings_scene)

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
