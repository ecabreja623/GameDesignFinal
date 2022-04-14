extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Barrel_body_entered(body):
	if body.is_in_group('player'):
		Globals.score += 1
		Globals.player_health -= 1
	return
