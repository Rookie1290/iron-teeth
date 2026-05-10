extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var open = false
@export var reverse:bool = false
@export var disabled:bool = false
var parent
var i = 0
@export var open_door = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_in_group("triggers"):
		parent = get_parent()




func trigger():
	if reverse == false:
		animation_player.play("open")
	else:
		animation_player.play("open2")
	open = true
	
func use():
	if disabled == false:
		$AudioStreamPlayer3D.play()
		if !open:
			if parent != null:
				parent.trigger()
				
			if reverse == false:
				animation_player.play("open")
			else:
				animation_player.play("open2")
		else:
			if parent != null:
				parent.glimmer()
			if reverse == false:
				animation_player.play("close")
			else:
				animation_player.play("close2")
		open = !open
func interact():
	use()
