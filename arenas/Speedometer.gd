extends CanvasLayer



func _process(delta):
	$MarginContainer/Needle.rotation_degrees =  abs(Globals.kph) - 90
	#print_debug(abs(Globals.kph))
