extends Area


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	rotate_y(deg2rad(30))

func _on_Timer_timeout():
	queue_free()

func _on_Mine_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	if _body.is_in_group("player"):
		Globals.mine_ready = true;
		$Timer.start()
