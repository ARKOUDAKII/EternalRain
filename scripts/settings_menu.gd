extends Control

# Metavliti gia na kserw an irtha apo to main menu h to pause
var caller : String = "main_menu"

# References stous sliders kai ta buttons
@onready var difficulty_slider  = $ScrollContainer/MarginContainer/VBoxContainer/DifficultySection/DifficultyHSlider
@onready var master_slider      = $ScrollContainer/MarginContainer/VBoxContainer/AudioSection/MasterContainer/MasterSlider
@onready var music_slider       = $ScrollContainer/MarginContainer/VBoxContainer/AudioSection/MusicContainer/MusicSlider
@onready var sfx_slider         = $ScrollContainer/MarginContainer/VBoxContainer/AudioSection/SFXContainer/SFXSlider

# References στα key binding buttons
@onready var move_left_btn   = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/MoveLeftRow/Button
@onready var move_right_btn  = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/MoveRightRow/Button
@onready var jump_btn        = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/JumpRow/Button
@onready var r_action_btn    = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/rActionRow/Button
@onready var l_action_btn    = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/lActionRow/Button
@onready var interact_btn       = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/InteractRow/Button
@onready var crouch_stealth_btn = $ScrollContainer/MarginContainer/VBoxContainer/ControlsSection/CrouchStealthRow/Button

# Poio button perimenei input apo ton xristi
var listening_button : Button = null

func _ready():
	_load_settings()
	_update_key_labels() # Αρχικοποίηση των labels των πλήκτρων

func _load_settings():
	# Διαβάζουμε τις τιμές απευθείας από το SaveManager config, αλλιώς βάζουμε τα defaults σου
	master_slider.value     = SettingsManager.config.get_value("Audio", "MasterVolume", 80.0)
	music_slider.value      = SettingsManager.config.get_value("Audio", "MusicVolume", 60.0)
	sfx_slider.value        = SettingsManager.config.get_value("Audio", "SFXVolume", 75.0)
	difficulty_slider.value = SettingsManager.config.get_value("Gameplay", "Difficulty", 1)

func _update_key_labels():
	move_left_btn.text   = _get_key_label("ui_left",  0)
	move_right_btn.text  = _get_key_label("ui_right", 0)
	jump_btn.text        = _get_key_label("jump", 0)
	r_action_btn.text    = _get_key_label("r_action", 0)
	l_action_btn.text    = _get_key_label("l_action", 0)
	interact_btn.text       = _get_key_label("interaction", 0)
	crouch_stealth_btn.text = _get_key_label("sneak", 0)

func _get_key_label(action_name: String, event_index: int = 0) -> String:
	var events = InputMap.action_get_events(action_name)
	if events.size() <= event_index:
		return "---"
		
	var event = events[event_index]
	if event is InputEventKey:
		if event.keycode == 0 and event.physical_keycode != 0:
			return OS.get_keycode_string(event.physical_keycode)
		else:
			return OS.get_keycode_string(event.keycode)
			
	return "???"

func _input(event):
	if listening_button == null:
		return
		
	if event is InputEventKey and event.pressed:
		var action_data = _get_action_and_index_for_button(listening_button)
		var action_name = action_data[0]
		var event_index = action_data[1]
		
		if action_name != "":
			var events = InputMap.action_get_events(action_name)
			
			if events.size() > event_index:
				var old_event = events[event_index]
				InputMap.action_erase_event(action_name, old_event)
			
			# Προσθήκη του νέου event
			InputMap.action_add_event(action_name, event)
			
			# Αποθήκευση του νέου Key Binding αμέσως στο αρχείο!
			SettingsManager.save_key_binding(action_name, event)
				
			if event.keycode != 0:
				listening_button.text = OS.get_keycode_string(event.keycode)
			else:
				listening_button.text = OS.get_keycode_string(event.physical_keycode)
			
		listening_button.release_focus()
		listening_button = null
		get_viewport().set_input_as_handled()

func _get_action_and_index_for_button(btn: Button) -> Array:
	match btn:
		move_left_btn:   return ["ui_left", 0]
		move_right_btn:  return ["ui_right", 0]
		jump_btn:        return ["jump", 0]
		r_action_btn:    return ["r_action", 0]
		l_action_btn:    return ["l_action", 0]
		interact_btn:       return ["interaction", 0]
		crouch_stealth_btn: return ["sneak", 0]
	return ["", 0]

# --- SIGNALS ---

func _on_move_left_button_pressed(): _start_listening(move_left_btn)
func _on_move_right_button_pressed(): _start_listening(move_right_btn)
func _on_jump_button_pressed(): _start_listening(jump_btn)
func _on_r_action_button_pressed(): _start_listening(r_action_btn)
func _on_l_action_button_pressed(): _start_listening(l_action_btn)
func _on_interact_button_pressed(): _start_listening(interact_btn)
func _on_crouch_stealth_button_pressed(): _start_listening(crouch_stealth_btn)

func _start_listening(btn: Button):
	listening_button = btn
	btn.text = "..."

# Αλλαγή ήχου σε real-time + Save στο αρχείο
func _on_master_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	SettingsManager.save_setting("Audio", "MasterVolume", value)

func _on_music_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	SettingsManager.save_setting("Audio", "MusicVolume", value)

func _on_sfx_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1: AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	SettingsManager.save_setting("Audio", "SFXVolume", value)

# Κουμπί Back
func _on_back_button_pressed():
	# Αποθηκεύουμε τη δυσκολία (οι ήχοι και τα πλήκτρα σώζονται αυτόματα τη στιγμή που αλλάζουν!)
	SettingsManager.save_setting("Gameplay", "Difficulty", difficulty_slider.value)
	queue_free()
