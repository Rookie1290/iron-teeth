extends Node3D
@onready var debris: GPUParticles3D = $debris
@onready var smoke: GPUParticles3D = $smoke
@onready var fire: GPUParticles3D = $fire
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D



func _ready() -> void:
	debris.emitting = true
	smoke.emitting = true
	fire.emitting = true
	audio_stream_player_3d.play()
