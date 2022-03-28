extends Area


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	rotate_y(deg2rad(30))


func _on_Powerup_body_entered(body):
	$Timer.start()


func _on_Timer_timeout():
	queue_free()
