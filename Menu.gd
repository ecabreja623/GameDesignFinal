extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/start.grab_focus()
	$VBoxContainer/Pantera.value = 4
	$VBoxContainer/Monster.value = 4
	$VBoxContainer/AI.value = 3
	if Globals.game_text == 'win':
		$GameState.text = "You Won!"
	elif Globals.game_text == 'lose':
		$GameState.text = "You Lose!"
	
	#$panteraText.text += str($VBoxContainer/Pantera.value)
	#$truckText.text += str($VBoxContainer/Monster.value)
	#$difficultyText.text += str($VBoxContainer/AI.value)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_start_pressed():
	get_tree().change_scene("res://arenas/arena.tscn")


func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()


func _on_AI_value_changed(value):
	Globals.ai_smartness = int(value)
	$VBoxContainer/AI/difficultyText.text = "AI Intelligence " + str($VBoxContainer/AI.value)
	#print(Globals.ai_smartness)


func _on_Monster_value_changed(value):
	Globals.num_monsters = int(value)
	$VBoxContainer/Monster/truckText.text = "Large Vehicle Count " + str($VBoxContainer/Monster.value)
	#print(Globals.num_monsters)


func _on_Pantera_value_changed(value):
	Globals.num_pantera = int(value)
	$VBoxContainer/Pantera/panteraText.text = "Small Vehicle Count " + str($VBoxContainer/Pantera.value)
	#print(Globals.num_pantera)
