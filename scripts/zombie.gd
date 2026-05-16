extends CharacterBody3D

var health = 125
var damage = 25
var die_points = 100
var hit_points = 10

@export var dummy := false
@export var speed: float = 3.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var vision_range := 40.0
var dead = false
@onready var body_mesh: MeshInstance3D = $MeshInstance3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var zombie_anim: AnimationPlayer = $"zombie rigged/AnimationPlayer"
@onready var vision_ray: RayCast3D = $"detection ray"
var waifu = false
var player: Node3D
var player_in_sight := true


func _ready() -> void:
	zombie_anim.play("ArmatureAction")
	
	if dummy:
		health = 100000
		speed = 0.0

	await get_tree().process_frame
	nav_agent.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	var target = get_target()
	# Update target if player visible

	# Vision check
	if target:
		nav_agent.target_position = target.global_position
		var dist := global_position.distance_to(target.global_position)
		if dist <= vision_range:
			look_at_player()
			#check_line_of_sight()
		#else:
			#player_in_sight = false

	# Navigation movement
	var next_pos := nav_agent.get_next_path_position()
	var dir := (next_pos - global_position)
	dir.y = 0

	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# ✅ ANIMATION CONTROL (THIS IS THE FIX)
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.1:
		if !dead:
			if not zombie_anim.is_playing():
				zombie_anim.play("ArmatureAction")
	else:
		zombie_anim.pause()

	move_and_slide()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func attack() -> void:
	if waifu == false:
		if !dead:
			animation_player.play("attack")
			$bite.play()


func take_damage(amount: int) -> void:
	health -= amount
	Global.points += hit_points
	if health <= 0:
		die()


func _on_attack_box_body_entered(body: Node3D) -> void:
	if body.has_method("player_health"):
		attack()


func _on_hit_box_body_entered(body: Node3D) -> void:
	if body.has_method("player_health"):
		body.player_health(damage)


func _on_attack_box_body_exited(_body: Node3D) -> void:
	animation_player.stop()


func die() -> void:
	Global.points += die_points
	dead = true
	self.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play("die")
	get_tree().call_group("zombie_spawner", "zombie_died")
	await animation_player.animation_finished
	
	queue_free()
	

func _on_detection_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		$AudioStreamPlayer3D.play()
		#player = body
		#player_in_sight = true

func look_at_player() -> void:
	var move_dir = velocity.normalized()

	if move_dir.length() > 0.1:
		var target = global_position + move_dir
		target.y = global_position.y
		look_at(target, Vector3.UP)
		
func check_line_of_sight() -> void:
	var origin := global_position + Vector3.UP * 1.5
	var target := player.global_position + Vector3.UP * 1.5

	vision_ray.global_position = origin
	vision_ray.target_position = vision_ray.to_local(target)
	vision_ray.force_raycast_update()
	
	
func get_target():
	var bombs = get_tree().get_nodes_in_group("waifu_bombs")
	
	if bombs.size() > 0:
		waifu = true
		return bombs[0]
	waifu = false
	return player
	
	
func waifu_bomb():
	get_target()
	
func waifu_gone():
	get_target()
	#if vision_ray.is_colliding() and vision_ray.get_collider() == player:
		#
		#
	#else:
		#player_in_sight = false
