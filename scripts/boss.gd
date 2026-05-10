extends CharacterBody3D

#@export var player_path: NodePath
@export var speed := 11
@export var health := 1200
var max_health = 1200
#@export var dr_path :NodePath
#@onready var dr = get_node(dr_path)
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim: AnimationPlayer = $AuxScene/AnimationPlayer


@export var dialogue: Array[String]
var spawn
var player: Node3D
var follow := false
var attack := false
var is_attacking := false
var is_dead := false
var i = 0
var b = 0
func _ready():
	spawn = global_position

	agent.target_desired_distance = 3.0

func _physics_process(delta):
	#if health <= 0:
		#if !anim.is:
			#if b == 0:
				#b +=1
				#anim.play("FallingBackDeath0")
	if Global.trigger_boss:
		player = get_tree().get_first_node_in_group("player")
		if i < 1:
			i += 1
			$AudioStreamPlayer3D.play()
			$CollisionShape3D.disabled = false
			$attackrange/CollisionShape3D.disabled = false
			visible = true
	else:
		return
	if is_dead:
		return
	
	if !is_attacking:
		agent.target_position = player.global_position
		
		if agent.is_navigation_finished():
			velocity = Vector3.ZERO
		else:
			var next_pos = agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			velocity = direction * speed
			
			if anim.current_animation != "Running1":
				anim.play("Running1")
		
		move_and_slide()
		
		if velocity.length() > 0.1:
			look_at(global_position + velocity, Vector3.UP)

# -----------------------
# ATTACK RANGE SIGNALS
# -----------------------

	
func _on_attackrange_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_dead:
		attack = true
		if not is_attacking:
			do_attack()

func _on_attackrange_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		attack = false   # stop FUTURE attacks only

# -----------------------
# ATTACK LOGIC
# -----------------------

func do_attack():
	if is_dead:
		return
	await  get_tree().create_timer(.5).timeout
	$"attack sound".play()
	is_attacking = true
	follow = false
	
	anim.play("ZombieAttack0")
	$AnimationPlayer.play("attack")
	if health > 0:
		await anim.animation_finished
	else:
		return

	
	
	
	
	# Decide what to do AFTER attack finishes
	if attack and not is_dead:
		do_attack()      # chain another attack
	else:
		is_attacking = false
		follow = true

# -----------------------
# HIT DETECTION
# -----------------------

func _on_hit_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_dead:
		body.player_health(35)

# -----------------------
# DAMAGE / DEATH
# -----------------------

func take_damage(amount):
	if is_dead:
		return
	
	health -= amount
	print(health)
	
	if health <= 0:
		die()

func die():
	is_dead = true
	follow = false
	attack = false
	is_attacking = false
	$"../win npc".visible = true
	anim.stop()
	anim.play("FallingBackDeath0")
	Global.boss_dead = true
	await anim.animation_finished

	$attackrange/CollisionShape3D.disabled = true
	$CollisionShape3D.disabled = true

func restart():
	global_position = spawn
	health = max_health
