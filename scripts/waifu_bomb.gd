extends RigidBody3D
@onready var timer: Timer = $Timer

@export var throw_force := 18.0
@export var upward_force := 4.0
@export var explosion_time := 5.0
var damage = 15
var moving = true
@onready var anim: AnimationPlayer = $AnimationPlayer
const EXPLOSION = preload("uid://btmfgw1657u8y")

func _ready():
	timer.wait_time = explosion_time
	timer.start()
	#get_tree().call_group("zombie","waifu_bomb",self)
	
func throw(direction: Vector3):
	linear_velocity = direction * -throw_force
	linear_velocity.y += upward_force

func _on_timer_timeout():
	explode()
	
	
func explode():
	var ins = EXPLOSION.instantiate()
	$Sprite3D.visible = false
	add_child(ins)
	get_tree().call_group("zombie","waifu_gone")
	anim.play("explosion")
	await anim.animation_finished
	queue_free()
	
	
func _physics_process(delta: float) -> void:
	if moving == true:
		if linear_velocity.length() < 0.1:
			add_to_group("waifu_bombs")
			moving = false
			timer.start()


func _on_blast_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("zombie"):
		body.take_damage(damage)
	print("waifu bomb")
