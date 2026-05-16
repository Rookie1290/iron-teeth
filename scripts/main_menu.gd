extends Control
@onready var settings: Control = $settings
@onready var sensitivity: HSlider = $settings/VBoxContainer/sensitivity
@onready var test_map: Node3D = $".."
var player
var game_started := false
var sens
@onready var round_manager: Node3D = $"../round_manager"

@onready var zombie_spawner: Node3D = $"../zombie_spawner"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sens = sensitivity.value

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if game_started:
			toggle_visible()

func _on_play_button_pressed() -> void:
	
	Global.sens = sens
	
	if not game_started:
		game_started = true
		test_map.start_game()
		
		round_manager.start_new_round()
		
	else:
		test_map.unpause()
	player = get_tree().get_first_node_in_group("player")
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle_visible():
	if visible:
		visible = false
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		visible = true
		if game_started:
			get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#player.ui.visible = !visible
	
func _on_settings_button_pressed() -> void:
	settings.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_apply_button_pressed() -> void:
	settings.visible = false
	Global.sens = sens
	if game_started:
		player.mouse_sens = sens


func _on_sensitivity_value_changed(value: float) -> void:
	sens = value
