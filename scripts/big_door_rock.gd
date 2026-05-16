extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var point_threshold: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact():
	print("Interact Door", Global.points)
	
	if Global.points >= point_threshold:	
		animation_player.play("open")
	else:
		print("Not Enough Points")
