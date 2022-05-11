extends Node


var kph = 0;

var player_health = 100;
var nitro_fuel = 100;
var enemies_left = 0;

var score = 0;

var power_ups_collected = 0;

var player_pos = Vector3.ZERO;
var mine_ready = false;
var shield_active = false;

var sec_elapsed = 0;
var min_elapsed = 0;

var num_monsters = 6; # range from 1 to 10
var num_pantera = 6; # range from 1 to 10
var ai_smartness = 3; # range form 1 to 5

var game_text = null



