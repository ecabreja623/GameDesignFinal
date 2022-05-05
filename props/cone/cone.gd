extends RigidBody

func _ready():
	pass

func _on_Cone_body_entered(body):
	if body.is_in_group('player'):
		Globals.score += 10
		Globals.player_health -= 1
	return
