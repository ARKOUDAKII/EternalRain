extends Node

const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
	# Μόλις ανοίγει το παιχνίδι, φορτώνει αυτόματα ήχους, δυσκολία και controls
	load_all_settings()

# --- ΑΠΟΘΗΚΕΥΣΗ ΗΧΟΥ / ΔΥΣΚΟΛΙΑΣ ---
func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	config.save(SAVE_PATH)

# --- ΑΠΟΘΗΚΕΥΣΗ KEY BINDINGS ---
func save_key_binding(action_name: String, event: InputEventKey) -> void:
	# Αποθηκεύουμε το physical_keycode για να αναγνωρίζεται σωστά σε κάθε πληκτρολόγιο
	config.set_value("Controls", action_name, event.physical_keycode)
	config.save(SAVE_PATH)

# --- ΚΕΝΤΡΙΚΗ ΦΟΡΤΩΣΗ ΚΑΙ ΕΦΑΡΜΟΓΗ ΟΛΩΝ ΤΩΝ ΡΥΘΜΙΣΕΩΝ ---
func load_all_settings() -> void:
	var error = config.load(SAVE_PATH)
	if error != OK:
		print("Δεν βρέθηκε αρχείο settings.cfg. Θα χρησιμοποιηθούν οι προεπιλογές.")
		return
	
	# 1. Φόρτωση και Εφαρμογή Ήχων στα Audio Buses
	if config.has_section_key("Audio", "MasterVolume"):
		var master_vol = config.get_value("Audio", "MasterVolume", 80.0)
		var bus = AudioServer.get_bus_index("Master")
		if bus != -1: AudioServer.set_bus_volume_db(bus, linear_to_db(master_vol / 100.0))
		
	if config.has_section_key("Audio", "MusicVolume"):
		var music_vol = config.get_value("Audio", "MusicVolume", 60.0)
		var bus = AudioServer.get_bus_index("Music")
		if bus != -1: AudioServer.set_bus_volume_db(bus, linear_to_db(music_vol / 100.0))

	if config.has_section_key("Audio", "SFXVolume"):
		var sfx_vol = config.get_value("Audio", "SFXVolume", 75.0)
		var bus = AudioServer.get_bus_index("SFX")
		if bus != -1: AudioServer.set_bus_volume_db(bus, linear_to_db(sfx_vol / 100.0))

	# 2. Φόρτωση Controls (Key Bindings)
	if config.has_section("Controls"):
		for action in config.get_section_keys("Controls"):
			var keycode = config.get_value("Controls", action)
			
			var new_event = InputEventKey.new()
			new_event.physical_keycode = keycode
			
			# Καθαρισμός του παλιού default κουμπιού και εισαγωγή του αποθηκευμένου
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, new_event)
