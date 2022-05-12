extends RigidBody

func _ready():
	pass

func _on_Cone_body_entered(body):
	if body.is_in_group('player') and not Globals.game_over:
		Globals.score += 10
		Globals.player_health -= 1
	return
