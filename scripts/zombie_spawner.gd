extends Node3D

var i = 0
var round = 0
var child_count : int
var spawners = []
var disabled = true
var cur_zombie = 0
var max_zombie = 20
var cur_round_zombie = 0
var max_round_zombie = 5
var rng = RandomNumberGenerator.new()
var speed = 2.0
var health = 100
var spawn_time = 4.0
var round_dead_zombie = 0
var player = Node3D
const ZOMBIE = preload("res://scenes/zombie.tscn")
@onready var timer: Timer = $spawn_mark/Timer
var max_zombies = 6
var spawning : bool

func _ready() -> void:
	
	print(child_count)
	await get_tree().create_timer(5).timeout
	player = Global.player
	disabled = true
	#next_round()
	
	
	
#func _process(delta: float) -> void:
	#print("round" , Global.cur_round_zombies)
	#print(Global.cur_zombies)
	##pass
	#if spawning == false:
		#if Global.cur_zombies < Global.max_zombies:
			#
			#if Global.cur_round_zombies < Global.max_round_zombies:
				#timer.start(.5)
				#print("jews")
				#spawning = true
			#
	#
	#
func zombie_died():
	cur_zombie -= 1
	round_dead_zombie += 1
	
func spawn_zombie():
	Global.cur_zombies += 1
	Global.cur_round_zombies += 1
	print(Global.cur_zombies)
	var instance = ZOMBIE.instantiate()
	#instance.health = health
	instance.player = player
	add_child(instance)


func _on_timer_timeout() -> void:
	spawn_zombie()
	spawning = false

func _process(delta: float) -> void:
	#print(cur_zombie)
	var children = get_children()


	child_count = spawners.size()
	var i = 0
	while i < children.size():
		#print(child_count)
		var child = children[i]
		if child.enabled == true:
			if not child in spawners:
				spawners.append(child)
		else:
			if child in spawners:
				spawners.erase(child)
				#print("jews")
		i += 1
	# To restart the loop, set i to 0
	i = 0
	
	
	
	if disabled == false:
		if cur_round_zombie < max_round_zombie:
			if cur_zombie < max_zombie:
				if spawners.size() > 0:
					disabled = true
					var random_num = rng.randi_range(0,child_count -1)
					var ins = ZOMBIE.instantiate()
					#if spawners[random_num].enabled == true:
					#print(random_num)
					ins.speed = speed
					ins.player = player
					ins.global_position = spawners[random_num].global_position
					ins.health = health
					get_tree().get_root().add_child(ins)
					cur_zombie += 1
					cur_round_zombie += 1 
					await get_tree().create_timer(spawn_time).timeout
					disabled = false
		elif round_dead_zombie == max_round_zombie:
			if i < 1:
				i += 1
				disabled_toggle()
				await get_tree().create_timer(5).timeout
				next_round()
				
func disabled_toggle():
	#print("disabled toggled ,", disabled)
	disabled = !disabled
	
	
func next_round():
	print("next_round")
	print(cur_round_zombie)
	if round < 5:
		health += 10
		speed += .75
		max_round_zombie += 3
		spawn_time -= 25
		print(health)
	else:
		speed = 5.5
		spawn_time = 1
		health *= 1.1
		max_round_zombie *= 1.15
	round += 1
	Global.round = round
	cur_round_zombie = 0
	max_round_zombie = round(max_round_zombie)
	round_dead_zombie = 0
	#print(round)
	i = 0
	disabled_toggle()
	
func start():
	disabled = false
	player = Global.player
