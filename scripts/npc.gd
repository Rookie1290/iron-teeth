extends CharacterBody3D

var i = -1
@export var dialogue :Array[String]
@export var id :String
@export var item_id : String
@export var item_texture : Texture
@export var gun_giver := false
@export var win: bool = false
var player
func _ready() -> void:
	
	$MeshInstance3D.visible = false
func _process(delta: float) -> void:
	if get_parent().visible == false:
		$CollisionShape3D.disabled = true
	if !visible:
		$CollisionShape3D.disabled = true
		
func interact():
	#print("npc interact")
	pass
	
func talk(playerx):
	player = playerx

	if win:
		get_tree().call_group("main","end_game")
		player.win()
		
		return
	else:
		i += 1
		if i < dialogue.size():
			if i == dialogue.size() - 1:
				
				give_item()
			#print(dialogue[i])
			return dialogue[i]
			
		else:

			i = -1
			return 

	
func take_damage(amount):
	print("npc take damage")
	
func give_item():
	if gun_giver:
		player.get_shotgun()
		
	if item_id != null:
		player.new_item(item_id, item_texture)
	if item_id == "Shotgun":
		Global.shotgun = true
	if item_id == "Figurine":
		Global.figurine = true
	if item_id == "Gameboy":
		Global.gameboy = true
	if item_id == "Apple Pie":
		Global.pie = true
	if item_id == "Medicine":
		Global.update_progress()
