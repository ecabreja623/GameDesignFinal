extends RigidBody

func _ready():
	pass

func _on_Dumptser_body_entered(body):
	if body.is_in_group('player'):
		Globals.score += 1
		Globals.player_health -= 1
	return
