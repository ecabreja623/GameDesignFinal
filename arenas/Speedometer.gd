extends CanvasLayer



func _process(_delta):
	$MarginContainer/Needle.rotation_degrees =  abs(Globals.kph) - 90
	#print_debug(abs(Globals.kph))
	
	if Globals.player_health <= 0:
		queue_free()
