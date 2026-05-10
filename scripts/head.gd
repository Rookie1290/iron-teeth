extends Node3D

var mouse_sens = .2
@onready var player: CharacterBody3D = $".."

func _ready() -> void:
	mouse_sens = Global.sens
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		
func _process(_delta: float) -> void:
	rotation.x = clamp(rotation.x, -1.4, 1)
	mouse_sens = player.mouse_sens
