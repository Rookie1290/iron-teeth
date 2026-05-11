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
@export var stamina_drain := 10.0     # per second
@export var stamina_regen := 10.0     # per second
@export var stam_regen_delay := 1        # delay after sprint stops
@onready var stamina_bar: TextureProgressBar = $CanvasLayer/ui/stamina_bar
const WAIFU_BOMB = preload("uid://c0nupokqbyans")

var stamina := max_stamina
var stam_regen_timer := 0.0

@export var regen_rate := 8.0       # HP per second
@export var regen_delay := 3.0       # seconds after last hit
var regen_timer := 0.0
@onready var damage_overlay: ColorRect = $"CanvasLayer/damage overlay"
@onready var camera: Camera3D = $head/Camera3D

@onready var interact_ray: RayCast3D = $"head/interact ray"
@onready var dialogue: Label = $"CanvasLayer/ui/dialogue rect/dialogue"

@onready var dialogue_timer: Timer = $"dialogue timer"
@onready var dialogue_rect: NinePatchRect = $"CanvasLayer/ui/dialogue rect"
@onready var npc_id: Label = $"CanvasLayer/ui/dialogue rect/npc id"

@onready var ui: Control = $CanvasLayer/ui


@onready var inv_display: NinePatchRect = $"CanvasLayer/ui/inv display"
@onready var item_info: Label = $"CanvasLayer/ui/inv display/HBoxContainer/item info"
@onready var item_rect: TextureRect = $"CanvasLayer/ui/inv display/HBoxContainer/item rect"



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_sens = Global.sens
	$head/Camera3D.current = true
	if Global.shotgun:
		get_shotgun()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))


		
func _physics_process(delta: float) -> void:
	Global.player_pos = global_position
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("g"):
		
		walk_speed = 15
	if Input.is_action_just_pressed("secondary_item"):
		throw_waifu()
		
		
	if Input.is_action_just_pressed("h"):
		walk_speed = 4
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		#velocity.x = JUMP_VELOCITY
		Global.update_progress()
		#get_shotgun()
		
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
	stamina_bar.value = stamina / max_stamina * 100.0
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	if interact_ray.is_colliding():
		if interact_ray.get_collider().has_method("interact"):
			$CanvasLayer/crosshair.text = "E"
	if !interact_ray.is_colliding():
		$CanvasLayer/crosshair.text = "."
	if interact_ray.is_colliding():
		
		if Input.is_action_just_pressed("interact"):
			interact(interact_ray.get_collider())
	$CanvasLayer/ui/fps.text = str(Engine.get_frames_per_second())
	
	var t = 1.0 - float(health) / float(max_health)
	t = clamp(t, 0.0, 1.0)
	
	var target_alpha = lerp(0.0, 0.7, 1.0 - float(health) / float(max_health))
	damage_overlay.color.a = lerp(
		damage_overlay.color.a,
		target_alpha,
		delta * 5.0
		)
		
	if health < max_health:
		if regen_timer > 0.0:
			regen_timer -= delta
		else:
			health += regen_rate * delta
			health = min(health, max_health)
			
			update_damage_overlay()
			
			
func interact(body):
	
	if !body.is_in_group("interact"):
		print("interact")
		return
	if body.has_method("talk"):
		talk(body)
	if body.has_method("interact"):
		#print("interact")
		body.interact()

func player_health(amount):
	
	health -= amount
	print("player hurt", health)
	health = max(health, 0)
	update_damage_overlay()
	regen_timer = regen_delay  # reset regen delay
	
	update_damage_overlay()    # your red screen function
	if health <= 0:
		die()

func throw_waifu():
	var ins = WAIFU_BOMB.instantiate()
	get_tree().current_scene.add_child(ins)
	ins.global_transform.origin = camera.global_transform.origin
	var dir = camera.global_transform.basis.z
	ins.throw(dir)
	
	


func die():
	print("playerr dead")
	queue_free()
	var main = get_tree().get_first_node_in_group("main")
	main.respawn()
	#get_tree().quit()
	
func update_damage_overlay():
	var t := 1.0 - float(health) / float(max_health)
	t = clamp(t, 0.0, 1.0)
	
	damage_overlay.color.a = lerp(0.0, 0.5, t)

func talk(npc):
	npc_id.text = npc.id
	dialogue_timer.stop()
	dialogue.text = ""
	var raw_text = npc.talk(self)
	if raw_text != null:
		#print(raw_text)
		dialogue.visible_characters = 0
		dialogue_rect.visible = true
		
		#var raw_text: String = npc.talk(self)
		var text := format_text(raw_text)
		
		dialogue.text = text
		
		for i in text.length():
			dialogue.visible_characters += 1
			await get_tree().create_timer(text_speed).timeout
	else:
		dialogue.text = "..."
	dialogue_timer.start(5)
	
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
	
func _on_dialogue_timer_timeout() -> void:
	dialogue_rect.visible = false
	
	
	#to do 
func new_item(item, texture):
	item_info.text = ""
	item_rect.texture = texture
	item_info.visible_characters = 0
	
	inv_display.visible = true
	item_info.text = item
	
	for i in item.length():
		item_info.visible_characters += 1
		await get_tree().create_timer(text_speed).timeout
	
	await get_tree().create_timer(3).timeout
	inv_display.visible = false
	

func win():
	visible = false
	$CanvasLayer.visible = false
	$head/Camera3D.current = false
	$"CanvasLayer/the end".visible = true
	
#todo pose chars, @fix ending, @fix dr jumpscare, @remove lamppost, new dialogue, left zombies for occulsion, zombie animation
 
