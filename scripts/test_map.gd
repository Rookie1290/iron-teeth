extends Node3D

@onready var menu_camera: Camera3D = $"menu camera"
@onready var main_menu: Control = $"main menu"
@onready var player_respawn: Marker3D = $player_respawn
@onready var the_end_label: Label = $"menu camera/CanvasLayer/the end label"

@onready var player_spawn: Marker3D = $"player spawn"
@onready var boss_spawn: Marker3D = $"boss spawn"

const PLAYER = preload("uid://ch24t0yop5qio")
const BOSS = preload("uid://dh767768h2n76")

var player
#
var dr_got = false

var i = 0
var v = 0
#@onready var bones: Node3D = $"../bones"
#@onready var corps_rigged: Node3D = $"../corps rigged"
#@onready var nic_sitting: Node3D = $"../nic sitting"
#@onready var granny_rigged: Node3D = $"../granny rigged"
#@onready var young_jon_rigged: Node3D = $"../young jon rigged"
#@onready var player: CharacterBody3D = $"../player"
#
var p_spawn_point
var boss_battle = false


		
func _ready() -> void:
	the_end_label.text = "IRON TEETH"
	menu_camera.current = true
	main_menu.visible = true
	p_spawn_point = player_spawn
	$music.play()
	
func start_game():
	$"anim bot6/man rigged".visible = false
	spawn_player()
	$music.stop()
	the_end_label.visible = false
	
func respawn():
	spawn_player()
	if boss_battle:
		spawn_boss()
		
		
		
func spawn_player():
	var ins = PLAYER.instantiate()
	if boss_battle:
		ins.global_transform = player_respawn.global_transform
	else:
		ins.global_transform = player_spawn.global_transform
	add_child(ins)
	player = ins
	
func spawn_boss():
	if boss_battle:
		var boss = get_tree().get_first_node_in_group("boss")
		boss.queue_free()
	var ins = BOSS.instantiate()
	ins.global_transform = boss_spawn.global_transform
	add_child(ins)
	boss_battle = true
	
func unpause():
	print("unpause")
	
func end_game():
	print("ding dong")
	main_menu.toggle_visible()
	the_end_label.visible = true
	the_end_label.text = "THE END"
	$"anim bot6/man rigged".visible = true
	$medicine.visible = true
	$music.play()
	if Global.figurine:
		$figurine.visible = true
	if Global.pie:
		$"apple pie".visible = true
	if Global.gameboy:
		$"anim bot/corps rigged".visible = false
		$"anim bot7/corps looking rigged".visible = true
		$gameboy.visible = true
	
	

	
func _on_progress_area_body_entered(body: Node3D) -> void:
		#player spawn
	if body.is_in_group("player"):
		if dr_got == true:
			Global.update_progress()
			if boss_battle == false:
				spawn_boss()
			


func _on_progress_area_2_body_entered(body: Node3D) -> void:
	#dr house
	if body.is_in_group("player"):
		if i == 0:
			$AnimationPlayer.play("dr jumpscare")
			$"sounds".enable()
			dr_got = true
#			Global.update_progress()

			i += 1


func _on_granny_jumpscare_body_entered(body: Node3D) -> void:
	if v == 0:
		if body.is_in_group("player"):
			$"AnimationPlayer".play("granny jumpscare")
			
			v += 1
			



func _on_final_area_body_entered(body: Node3D) -> void:
	
	if Global.boss_dead:
		if body.is_in_group("player"):
			$"win npc".visible = true
			$"anim bot/corps rigged/npc".visible = false
