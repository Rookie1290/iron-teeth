# player.gd
extends CharacterBody3D

var walk_speed = 4
const sprint_speed = 6
var speed = 4.0
const JUMP_VELOCITY = 4.5

var mouse_sens = .2
var text_speed = .03
var max_char = 26

var max_health = 100
var health = 100

@export var max_stamina := 100.0
@export var stamina_drain := 10.0
@export var stamina_regen := 10.0
@export var stam_regen_delay := 1.0

var stamina := max_stamina
var stam_regen_timer := 0.0

@export var regen_rate := 8.0
@export var regen_delay := 3.0

var regen_timer := 0.0

const WAIFU_BOMB = preload("uid://c0nupokqbyans")

@onready var camera: Camera3D = $head/Camera3D
@onready var interact_ray: RayCast3D = $"head/interact ray"

@onready var ui = get_tree().get_first_node_in_group("ui")

func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sens = Global.sens
	camera.current = true
	
	if Global.shotgun:
		get_shotgun()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))

func _physics_process(delta: float) -> void:
	Global.player_pos = global_position

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("secondary_item"):
		throw_waifu()

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	var is_sprinting := Input.is_action_pressed("sprint")
	var can_sprint := stamina > 5.0

	if is_sprinting and can_sprint:
		speed = sprint_speed
		stamina -= stamina_drain * delta
		stamina = max(stamina, 0.0)
		stam_regen_timer = stam_regen_delay
	else:
		speed = walk_speed

		if stam_regen_timer > 0.0:
			stam_regen_timer -= delta
		else:
			stamina += stamina_regen * delta
			stamina = min(stamina, max_stamina)

	ui.update_stamina(stamina / max_stamina * 100.0)

	var input_dir := Input.get_vector("left", "right", "up", "down")

	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	handle_interaction()

	ui.update_fps()

	ui.update_damage_overlay(
		health,
		max_health,
		delta
	)

	if health < max_health:
		if regen_timer > 0.0:
			regen_timer -= delta
		else:
			health += regen_rate * delta
			health = min(health, max_health)

func handle_interaction():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()

		if collider.has_method("interact"):
			ui.set_crosshair("E")
		else:
			ui.set_crosshair(".")

		if Input.is_action_just_pressed("interact"):
			interact(collider)
	else:
		ui.set_crosshair(".")

func interact(body):
	if !body.is_in_group("interact"):
		return

	if body.has_method("talk"):
		talk(body)

	if body.has_method("interact"):
		body.interact()

func talk(npc):
	var raw_text = npc.talk(self)

	if raw_text != null:
		var text := format_text(raw_text)

		ui.show_dialogue(
			npc.id,
			text,
			text_speed
		)

func player_health(amount):
	health -= amount
	health = max(health, 0)

	regen_timer = regen_delay

	if health <= 0:
		die()

func die():
	var main = get_tree().get_first_node_in_group("main")
	#main.respawn()

func throw_waifu():
	if ui.waifu_bar.value == 100:
		var ins = WAIFU_BOMB.instantiate()
		ui.update_waifu()
		get_tree().current_scene.add_child(ins)

		ins.global_transform.origin = camera.global_transform.origin

		var dir = camera.global_transform.basis.z

		ins.throw(dir)

func get_shotgun():
	$head/Camera3D/shotgun.visible = true
	$head/Camera3D/shotgun.holding_gun = true

func format_text(text: String) -> String:
	var words = text.split(" ")
	var line := ""
	var result := ""

	for word in words:
		if line.length() + word.length() + 1 > max_char:
			result += line.strip_edges() + "\n"
			line = word + " "
		else:
			line += word + " "

	result += line.strip_edges()

	return result

func new_item(item, texture):
	ui.show_item(item, texture)

func win():
	visible = false
	camera.current = false
	ui.show_ending()
