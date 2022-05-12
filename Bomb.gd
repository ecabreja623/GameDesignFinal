extends Spatial

var countdown = 3;
var exploded = false;
var floating_text = preload("res://floatingtext.tscn")

func _ready():
	# start ticking / counting down
	pass

func _physics_process(delta):
	
	countdown -= delta;
	
	if (countdown <= 0):
		
		if not exploded:
			exploded = true;
			_explode();
			print_debug("BOOM")
			
		# explode + do animation

func _explode():
	
	
	get_node("AnimationPlayer").play("explosion")
	
	var victims = $BlastArea.get_overlapping_bodies();
	
	for victim in victims:
		var text = floating_text.instance()
		
		if victim.is_in_group("player") and not Globals.game_over:
			Globals.player_health -= 15;
			
			print_debug("player damaged by bomb")
			
		elif victim.is_in_group("enemy"):
			# this damage could be displayed on the side (out of view damage)
			var enemydamage =  50
			victim.health -= enemydamage
			text.amount = enemydamage
			add_child(text)
			
			victim.update_healthbar(victim.health, victim.max_health)
			
			Globals.score += 100
			if victim.health <= 0:
				Globals.score += 500
			print_debug("enemy damaged by bomb")
	
	yield(get_node("AnimationPlayer"), "animation_finished")
	queue_free()

func _on_Area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	var text = floating_text.instance()
	
	if body.is_in_group("enemy"):
		if not exploded:
			_explode();

			
			var enemydamage =  10
			body.health -= enemydamage
			text.amount = enemydamage
			add_child(text)
			
			body.update_healthbar(body.health, body.max_health)
			
			print_debug("enemy ran into bomb")
		
	if body.is_in_group("player"):
		if countdown < 2:
			if not exploded:
				_explode();
				print_debug("player ran into bomb")
