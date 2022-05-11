extends Label



func _ready():
	return 

func display_text():
	# self.text = "Health: " + str(Globals.player_health)
	self.text =  "Score:" + str(Globals.score)
	# self.text += '\n' + "Nitro:" + str(Globals.nitro_fuel)
	#self.text += '\n' + "Power ups:" + str(Globals.power_ups_collected)
	# self.text += '\n' + "Gear:" + str(Globals.gear)
	self.text += '\n' + "Enemies left: " + str(Globals.enemies_left)
	#self.text += '\n' + "Health Enemy2: " + str(Globals.enemy_health2)
	#self.text += '\n' + "Speed(KPH):" + str(Globals.kph)
	self.text += '\n' + "Time Elapsed: " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2)
	return
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.player_health > 0 and Globals.enemies_left > 0:
		Globals.sec_elapsed += _delta;
		if Globals.sec_elapsed >= 60:
			Globals.sec_elapsed = 0
			Globals.min_elapsed += 1
		display_text()
	else:
		self.text = ""
