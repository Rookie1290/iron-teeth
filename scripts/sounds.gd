extends Node3D
@export var sound : AudioStream
var dr = false
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if dr:
			$AudioStreamPlayer3D.stream = sound
			$AudioStreamPlayer3D.play()
			print("sound")
		else:
			return


func enable():
	dr = true
