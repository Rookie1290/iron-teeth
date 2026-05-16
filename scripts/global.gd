extends Node


var player_pos = Vector3(0,0,0)
var i = 0
var trigger_boss = false
var points = 0
var sens = .04
var shotgun = false
var pie = false
var gameboy = false
var figurine = false
var boss_dead = false
var max_round_zombies = 0
var cur_zombies = 0
var cur_round_zombies = 0
var round = 0
var player
func update_progress():
	i += 1
	if i == 2:
		trigger_boss = true
		
