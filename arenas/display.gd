extends Label

func _ready():
	return 

func display_text():
	# self.text = "Health: " + str(Globals.player_health)
	self.text =  "Score:" + str(int(Globals.score))
	# self.text += '\n' + "Nitro:" + str(Globals.nitro_fuel)
	#self.text += '\n' + "Power ups:" + str(Globals.power_ups_collected)
	# self.text += '\n' + "Gear:" + str(Globals.gear)
	self.text += '\n' + "Enemies left: " + str(Globals.enemies_left)
	#self.text += '\n' + "Health Enemy2: " + str(Globals.enemy_health2)
	#self.text += '\n' + "Speed(KPH):" + str(Globals.kph)
	
	if Globals.mine_ready:
		self.text += "\n" + "Mine Equipped"
	return
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.player_health > 0 and Globals.enemies_left > 0:
		display_text()
	else:
		self.text = ""
