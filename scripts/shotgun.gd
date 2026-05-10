extends Node3D

@onready var camera: Camera3D = $".."
@onready var gun_ray: RayCast3D = $"../gun ray"
@onready var shot: GPUParticles3D = $shot

@onready var smoke: GPUParticles3D = $smoke
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var damage := 14
@export var pellets := 8
@export var spread := 0.1
@export var range := 50.0
@export var fire_rate := 1.1
var holding_gun = false

var can_shoot := true

func _input(event):
	if holding_gun:
		if event.is_action_pressed("shoot") and can_shoot:
			shoot()

func shoot():
	can_shoot = false
	anim.play("shoot")
	#print("shot")
	for i in pellets:
		fire_pellet()
	
	
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func fire_pellet():
	var origin = camera.global_transform.origin
	
	var direction = -camera.global_transform.basis.z
	direction.x += randf_range(-spread, spread)
	direction.y += randf_range(-spread, spread)
	direction = direction.normalized()
	
	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * range
	)
	query.exclude = [self]
	
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result:
		if result.collider.has_method("take_damage"):
			#print(result.collider)
			result.collider.take_damage(damage)
