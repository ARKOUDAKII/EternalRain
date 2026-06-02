extends Control

# Metavliti gia na kserw an irtha apo to main menu h to pause
var caller : String = "main_menu"

# References stous sliders kai ta buttons
@onready var difficulty_slider  = $MarginContainer/ScrollContainer/VBoxContainer/DifficultySection/DifficultyHSlider
@onready var master_slider      = $MarginContainer/ScrollContainer/VBoxContainer/AudioSection/MasterContainer/MasterSlider
@onready var music_slider       = $MarginContainer/ScrollContainer/VBoxContainer/AudioSection/MusicContainer/MusicSlider
@onready var sfx_slider         = $MarginContainer/ScrollContainer/VBoxContainer/AudioSection/SFXContainer/SFXSlider

# References sta key binding buttons
@onready var move_left_btn   = $MarginContainer/ScrollContainer/VBoxContainer/ControlsSection/MoveLeftRow/Button
@onready var move_right_btn  = $MarginContainer/ScrollContainer/VBoxContainer/ControlsSection/MoveRightRow/Button
@onready var jump_btn        = $MarginContainer/ScrollContainer/VBoxContainer/ControlsSection/JumpRow/Button
@onready var r_action_btn    = $MarginContainer/ScrollContainer/VBoxContainer/ControlsSection/rActionRow/Button
@onready var l_action_btn    = $MarginContainer/ScrollContainer/VBoxContainer/ControlsSection/lActionRow/Button

# Poio button perimenei input apo ton xristi
var listening_button : Button = null

func _ready():
	# Αρχικοποίηση των labels των πλήκτρων
	_update_key_labels()

func _update_key_labels():
	# Στοχεύουμε σωστά το "directional.x" με βάση το Input Map του project
	move_left_btn.text   = _get_key_label("directional.x", 0) # 1ο event (Left)
	move_right_btn.text  = _get_key_label("directional.x", 1) # 2ο event (Right)
	jump_btn.text        = _get_key_label("jump", 0)
	r_action_btn.text    = _get_key_label("r_action", 0)
	l_action_btn.text    = _get_key_label("l_action", 0)

func _get_key_label(action_name: String, event_index: int = 0) -> String:
	var events = InputMap.action_get_events(action_name)
	if events.size() <= event_index:
		return "---"
		
	var event = events[event_index]
	if event is InputEventKey:
		# Physical Key, παίρνουμε το physical_keycode
		if event.keycode == 0 and event.physical_keycode != 0:
			return OS.get_keycode_string(event.physical_keycode)
		else:
			return OS.get_keycode_string(event.keycode)
			
	return "???"

func _input(event):
	if listening_button == null:
		return
		
	if event is InputEventKey and event.pressed:
		# 1. Βρες ποιο action και ποιο event_index αντιστοιχεί στο κουμπί
		var action_data = _get_action_and_index_for_button(listening_button)
		var action_name = action_data[0]
		var event_index = action_data[1]
		
		if action_name != "":
			var events = InputMap.action_get_events(action_name)
			
			# Αν υπάρχει ήδη event σε αυτή τη θέση, το αντικαθιστούμε
			if events.size() > event_index:
				var old_event = events[event_index]
				InputMap.action_erase_event(action_name, old_event)
				
				# Πατέντα για να κρατήσουμε τη σωστή σειρά στο directional.x
				# Αν αλλάξουμε το Left (0), πρέπει να βγει και το Right (1) και να ξαναμπούν με τη σειρά
				if event_index == 0 and events.size() > 1:
					var right_event = events[1] # Επειδή σβήσαμε το 0, το παλιό index 1 έγινε τώρα index 0
					InputMap.action_erase_event(action_name, right_event)
					InputMap.action_add_event(action_name, event)       # Νέο Left (Μπαίνει 1ο)
					InputMap.action_add_event(action_name, right_event)  # Παλιό Right (Μπαίνει 2ο)
				else:
					InputMap.action_add_event(action_name, event)
			else:
				# Αν για κάποιο λόγο δεν υπήρχε, απλά το προσθέτουμε
				InputMap.action_add_event(action_name, event)
				
			listening_button.text = OS.get_keycode_string(event.keycode)
			
		listening_button.release_focus()
		listening_button = null
		get_viewport().set_input_as_handled()

func _get_action_and_index_for_button(btn: Button) -> Array:
	# Αντιστοίχιση των κουμπιών στα πραγματικά Actions και τα indexes τους
	match btn:
		move_left_btn:   return ["directional.x", 0]
		move_right_btn:  return ["directional.x", 1]
		jump_btn:        return ["jump", 0]
		r_action_btn:    return ["r_action", 0]
		l_action_btn:    return ["l_action", 0]
	return ["", 0]

# --- SIGNALS ---

func _on_move_left_button_pressed():
	_start_listening(move_left_btn)

func _on_move_right_button_pressed():
	_start_listening(move_right_btn)

func _on_jump_button_pressed():
	_start_listening(jump_btn)

func _on_r_action_button_pressed():
	_start_listening(r_action_btn)

func _on_l_action_button_pressed():
	_start_listening(l_action_btn)

func _start_listening(btn: Button):
	listening_button = btn
	btn.text = "..."

func _on_master_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _on_music_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _on_sfx_slider_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _on_back_button_pressed():
	_save_settings()
	queue_free() # Αφού είναι overlay, απλά το κλείνουμε για να αποκαλυφθεί το από κάτω μενού

func _save_settings():
	# Προσωρινή αποθήκευση (θα το γυρίσουμε σε ConfigFile αργότερα όπως είπαμε)
	ProjectSettings.set_setting("audio/master_volume", master_slider.value)
	ProjectSettings.set_setting("audio/music_volume",  music_slider.value)
	ProjectSettings.set_setting("audio/sfx_volume",   sfx_slider.value)
	ProjectSettings.set_setting("game/difficulty",     difficulty_slider.value)
	ProjectSettings.save()
