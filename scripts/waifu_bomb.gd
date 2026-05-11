extends RigidBody3D

@export var throw_force := 18.0
@export var upward_force := 4.0
@export var explosion_time := 3.0

func _ready():
	$Timer.wait_time = explosion_time
	$Timer.start()

func throw(direction: Vector3):
	linear_velocity = direction * -throw_force
	linear_velocity.y += upward_force

func _on_timer_timeout():
	explode()

func explode():
	queue_free()
