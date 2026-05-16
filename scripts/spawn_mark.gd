extends Marker3D


var enabled = false










func _on_in_range_area_entered(area: Area3D) -> void:
	enabled = true
	#print(enabled)

func _on_in_range_area_exited(area: Area3D) -> void:
	enabled = false
	#print(enabled)
