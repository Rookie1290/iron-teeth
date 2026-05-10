extends Node3D

func _ready() -> void:
	var bing = get_child(0)
	var bong = bing.get_child(1)
	bong.play("ArmatureAction")
