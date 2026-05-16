# ui.gd
extends CanvasLayer

@onready var stamina_bar: TextureProgressBar = $ui/stamina_bar
@onready var damage_overlay: ColorRect = $"damage overlay"

@onready var crosshair: Label = $crosshair
@onready var fps: Label = $ui/fps

@onready var dialogue: Label = $"ui/dialogue rect/dialogue"
@onready var dialogue_rect: NinePatchRect = $"ui/dialogue rect"
@onready var npc_id: Label = $"ui/dialogue rect/npc id"
@onready var dialogue_timer: Timer = $"dialogue timer"

@onready var inv_display: NinePatchRect = $"ui/inv display"
@onready var item_info: Label = $"ui/inv display/HBoxContainer/item info"
@onready var item_rect: TextureRect = $"ui/inv display/HBoxContainer/item rect"

@onready var ending = $"the end"
@onready var waifu_bar: TextureProgressBar = $"ui/waifu bar"
var temp_val = 0.0

func _process(delta: float) -> void:
	if waifu_bar.value < waifu_bar.max_value:
		temp_val += .1
		waifu_bar.value = temp_val
		#print("waifu bomb value:", waifu_bar.value)

func update_stamina(value):
	stamina_bar.value = value
	
func set_crosshair(text):
	crosshair.text = text
	
func update_fps():
	fps.text = str(Engine.get_frames_per_second())
	
func update_damage_overlay(
	health,
	max_health,
	delta
):
	var t := 1.0 - float(health) / float(max_health)
	t = clamp(t, 0.0, 1.0)
	var target_alpha = lerp(
		0.0,
		0.7,
		t
	)
	damage_overlay.color.a = lerp(
		damage_overlay.color.a,
		target_alpha,
		delta * 5.0
	)

func show_dialogue(
	id,
	text,
	text_speed
):
	dialogue_timer.stop()
	dialogue.text = ""
	npc_id.text = id
	dialogue.visible_characters = 0
	dialogue_rect.visible = true
	dialogue.text = text

	for i in text.length():
		dialogue.visible_characters += 1
		await get_tree().create_timer(
			text_speed
		).timeout

	dialogue_timer.start(5)

func _on_dialogue_timer_timeout():
	dialogue_rect.visible = false

func show_item(item, texture):
	item_info.text = ""

	item_rect.texture = texture

	item_info.visible_characters = 0

	inv_display.visible = true

	item_info.text = item

	for i in item.length():
		item_info.visible_characters += 1
		await get_tree().create_timer(.03).timeout

	await get_tree().create_timer(3).timeout

	inv_display.visible = false

func update_waifu():
	waifu_bar.value = 0
	temp_val = 0

func show_ending():
	visible = false
	ending.visible = true
