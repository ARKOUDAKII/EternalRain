extends Node2D

@export var player: CharacterBody2D;
@onready var equipment_handler = player.equipment_handler;

enum PickupCatalog {
	TORCH,
	FIREORB,
	HAMMER,
	SEW
}

func apply_effect(pickup: PickupCatalog):
	
	match pickup:
		PickupCatalog.TORCH:
			if player.HP + 20.0 > 100.0:
				player.HP = 100.0
			else:
				player.HP += 20.0
		PickupCatalog.FIREORB:
			player.SPOINTS += 1
			player.skill_tree.update_label()
		PickupCatalog.HAMMER:
			if equipment_handler.cureq["Equipped"] == "HELM":
				equipment_handler.cureq["Boon"] += 20.0
		PickupCatalog.SEW:
			if equipment_handler.cureq["Equipped"] == "HAT" or equipment_handler.cureq["Equipped"] == "ClOAK":
				equipment_handler.cureq["Boon"] += 20.0
		_:
			print("ERROR IN PICKUP HANDLER")
	player.update_label()
	#player.update_light()
