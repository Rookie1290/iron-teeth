extends CharacterBody3D

@export var player_path: NodePath
@export var speed := 3.5

@onready var agent: NavigationAgent3D = $NavigationAgent3D
var player: Node3D
var follow = false

var i = -1
@export var dialogue :Array[String]
@export var id :String
@export var item_id : String
@export var item_texture : Texture
signal dr_bing

func _ready():
	player = get_node(player_path)
	agent.target_desired_distance = 3.0

func _physics_process(delta):
	if player == null:
		return
	if follow:
		agent.target_position = player.global_position
		
		if agent.is_navigation_finished():
			velocity = Vector3.ZERO
		else:
			var next_pos = agent.get_next_path_position()
			var direction = (next_pos - global_position).normalized()
			velocity = direction * speed
		
		move_and_slide()
		if velocity.length() > 0.1:
			look_at(global_position + velocity, Vector3.UP)
			
func interact():
	#follow = true
	#talk()
	pass
	
func talk(playerx):
	player = playerx
	i += 1
	if i < dialogue.size():
		return dialogue[i]
	else:
		give_item()
		dr_bing.emit()
		follow = true
		i = -1
		return ""
	
func give_item():
	if item_id != null:
		player.new_item(item_id, item_texture)
