extends Node2D

var scene = preload("res://scenes/rigid_body_2d.tscn")

var head: AnimatedSprite2D;
@export var player: CharacterBody2D;
#@onready var area_2d: Area2D = $Area2D

var EquipmentCatalog = [
	"NONE",
	"HELM",
	"HAT",
	"CLOAK"
]

var cureq: Dictionary
var msg = "Hello"

func _ready() -> void:
	head = player.Head
	if !cureq:
		cureq = {
			"Equipped": "NONE",
			"Boon": 0.0
		}

func equip(equipment: String, boon: float) -> void:
	if equipment not in EquipmentCatalog:
		pass
	else:
		cureq["Equipped"] = equipment
		cureq["Boon"] = boon
		head.change_head(equipment)

func equip_d(data: Dictionary) -> void:
	if cureq["Equipped"] != "NONE":
		unequip()
		
	if data["Type"] not in EquipmentCatalog:
		pass
	else:
		cureq["Equipped"] = data["Type"]
		cureq["Boon"] = data["Boon"]
		head.change_head(data["Type"])
	player.update_label();

func unequip() -> void:
	if cureq["Equipped"] != "NONE":
		var eqpmnt = scene.instantiate()
		eqpmnt.ImportedEquipment = cureq["Equipped"]
		eqpmnt.ImportedBoon = cureq["Boon"]
		eqpmnt.position = get_parent().position
		head.change_head("NONE")
		get_tree().current_scene.add_child(eqpmnt)
		cureq = {
				"Equipped": "NONE",
				"Boon": 0.0
			}
	player.update_label();
	
func damage_equipment(damage: float) -> void:
	if cureq["Boon"] - damage <= 0:
		cureq["Boon"] = 0
	else:
		cureq["Boon"] = cureq["Boon"] - damage
	player.update_label()
