extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	print("inside")
	if body.is_in_group('player'):
		print("hello")
		body.nitro_fuel += 50
		if body.nitro_fuel > 100 :
			body.nitro_fuel = 100
		print(body.nitro_fuel)	
	
