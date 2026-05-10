extends Area3D
var dr_got = false

var i = 0
var v = 0
@onready var bones: Node3D = $"../bones"
@onready var corps_rigged: Node3D = $"../corps rigged"
@onready var nic_sitting: Node3D = $"../nic sitting"
@onready var granny_rigged: Node3D = $"../granny rigged"
@onready var young_jon_rigged: Node3D = $"../young jon rigged"
@onready var player: CharacterBody3D = $"../player"



func _on_body_entered(body: Node3D) -> void:
	#player spawn
	if body.is_in_group("player"):
		if dr_got == true:
			Global.update_progress()
			



func _on_progress_area_2_body_entered(body: Node3D) -> void:
	#dr house
	if body.is_in_group("player"):
		if i == 0:
			$"../AnimationPlayer".play("dr jumpscare")
			$"../sounds".enable()
			dr_got = true
#			Global.update_progress()

			i += 1


func _on_granny_jumpscare_body_entered(body: Node3D) -> void:
	if v == 0:
		if body.is_in_group("player"):
			$"../AnimationPlayer".play("granny jumpscare")
			
			v += 1
			



func _on_final_area_body_entered(body: Node3D) -> void:
	
	if Global.boss_dead:
		if body.is_in_group("player"):
			$"../win npc".visible = true
			$"../corps rigged/npc".visible = false
