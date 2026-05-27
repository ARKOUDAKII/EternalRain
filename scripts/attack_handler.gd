extends Node2D

var fireball_scene = preload("res://scenes/fireball.tscn")

var equipment_handler: Node2D 
var skill_tree: Node2D
@export var player: CharacterBody2D

var equipment_bonus: float;

func _ready() -> void:
	equipment_handler = player.equipment_handler
	skill_tree = player.skill_tree

func dash() -> float:
	if equipment_handler.cureq["Equipped"] == "HELM" and equipment_handler.cureq["Boon"] > 0:
		equipment_bonus = 10
		equipment_handler.damage_equipment(20.0)
		player.update_label()
	else:
		equipment_bonus = 0
		player.player_hit(20)
	return (20+skill_tree.dash_bonus+equipment_bonus)
	
func fireball(bonus_damage: float, cost: float) -> void:
	if equipment_handler.cureq["Equipped"] == "HAT" and equipment_handler.cureq["Boon"] > 0:
		equipment_bonus = 10
		equipment_handler.damage_equipment(cost)
		player.update_label()
		spawn_fireball(bonus_damage)
	elif player.HP > cost/2:
		equipment_bonus = 0
		player.player_hit(cost/2)
		spawn_fireball(bonus_damage)
	else:
		pass
		
func detonate() -> void:
	pass
	
func spawn_fireball(bonus_damage: float) -> void:
	var facing: int;
	if player.Head.flip_h:
		facing = -1;
	else:
		facing = 1;
	var fireball = fireball_scene.instantiate()
	fireball.position = player.position 
	fireball.damage = ((50+skill_tree.fireball_bonus+equipment_bonus)*bonus_damage)
	fireball.SPEED_V = 400
	fireball.SPEED_H = 0
	fireball.ANGLE = 0 + 180*((1-(facing))/2)
	get_tree().current_scene.add_child(fireball)
