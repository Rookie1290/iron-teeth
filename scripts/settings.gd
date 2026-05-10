extends Control

var vol : float
var muted = false
var res: = Vector2(1920,1080)
var fullbool = true
var sens
var main_menu = true

@onready var volume: HSlider = $MarginContainer/VBoxContainer/volume
@onready var mute: CheckBox = $MarginContainer/VBoxContainer/mute
@onready var resolutions: OptionButton = $MarginContainer/VBoxContainer/resolutions
@onready var fullscreen: CheckBox = $MarginContainer/VBoxContainer/fullscreen
@onready var sensitivity: HSlider = $MarginContainer/VBoxContainer/sensitivity



func _ready() -> void:
	
	set_values()
	DisplayServer.window_set_size(res)
	
func set_values():
	#print("mommy milkers")
	volume.value = Global.volume
	mute.button_pressed = Global.mute
	resolutions.select(Global.resolution)
	fullscreen.button_pressed = Global.fullscreen
	sensitivity.value = Global.sens


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0,value)
	vol = value

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	muted = toggled_on

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			#DisplayServer.window_set_size(Vector2i(1920,1080))
			res = Vector2(1920,1080)
		1:
			#DisplayServer.window_set_size(Vector2i(1600,900))
			res = Vector2(1600,900)
		2:
			#DisplayServer.window_set_size(Vector2i(1280,720))
			res = Vector2(1280,720)


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		fullbool = true
		 
	else:
		fullbool = false
		


func _on_sensitivity_value_changed(value: float) -> void:
	sens = value


func _on_apply_pressed() -> void:
	if fullbool == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(res)
	Global.volume = vol
	Global.mute = muted
	Global.resolution = resolutions.selected
	Global.fullscreen = fullbool
	Global.sens = sens
