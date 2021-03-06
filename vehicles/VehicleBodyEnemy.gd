extends VehicleBody

var floating_text = preload("res://floatingtext.tscn")
# Member variables
var health = 100
var max_health = 100

export var steering_max_angle = 0.70
export var steering_speed = 4.0
export var steering_percent_drop = 0.75
export var steering_from_speed = 18
export var steering_to_speed = 90

var steering_speed_range = 0
var steering_target = 0
var steering_angle = 0

var num_frame = 0
var wheel_contact = 0
var throttle = 0;
var brakes = false
var start_sound = false

var groups_list = []
var path = []
var curr_path_index = 0
var target = null

onready var nav = get_parent().get_parent()

var has_powerup = false;

#Alternative A
export var torque_curve_rpms = [500, 5000, 5500, 6500, 7500, 9000]
export var torque_curve_torques = [400, 1100, 1300, 1800, 1600, 0]

#Alternative B
export var torque_curve = [Vector2(500,400), Vector2(5000, 1100), Vector2(5500, 1300), 
						   Vector2(6500, 1800), Vector2(7500, 1600), Vector2(9000, 0)]


export var gear_ratios = [-4.25, 3.2, 2.24, 1.57, 1.23, 1.065]
export var differential_ratio = 2.1
export var transmission_efficiency = 0.75
export var friction_coefficient = -0.8
export var drag_coefficient = -0.8
export var brake_strength = 25


var current_gear
var spin_out = 8
export var slip_speed = 9.0
export var traction_slow = 0.75
export var traction_fast = 0.02

var drifting = false
export var has_handbrake = true

var kph;
var despawn = false;
var enem_follow = 0;
var airborne = false;

var despawn_wait = 3;

func set_health(temp_string):
	var health_bar = load("res://assets/Healthbar3D.tscn").instance()
	if temp_string == 'pantera':
		health_bar.translation.y += 1.52
	elif temp_string == 'monster':
		health_bar.translation.y += 1.72
	add_child(health_bar)

var ray = null

func _ready():
	ray = get_node("RayCast")
	Globals.enemies_left += 1
	groups_list = get_groups()
	if 'enemy1' in groups_list:
		set_health('pantera')
	else:
		set_health('monster')
	groups_list = get_groups()
	steering_speed_range = steering_to_speed - steering_from_speed
	current_gear = 1
	

func _exit_tree():
	Globals.enemies_left -= 1
	

func _physics_process(delta):
	if num_frame > 100:
		if 'enemy1' in groups_list:
			apply_impulse(Vector3(1, 0, 0), Vector3(0, mass * 2, 0))
			num_frame = 40
		elif 'enemy2' in groups_list:
			apply_impulse(Vector3(1, 0, 0), Vector3(0, mass * 3.3, 0))
			num_frame = 20
		
		# print('upside down')
	if Input.is_action_pressed("enemy_destory"):
		health -= 1
		$Healthbar3D.update(health, max_health)

	if health <= 0:
		despawn = true
		$Explosion._explosion()
		#get_node("AnimationPlayer").play("despawn")
		#yield(get_node("AnimationPlayer"), "animation_finished")
		despawn_wait -= delta;
		if despawn_wait <= 0:
			queue_free()
	
	if !(get_node("VehicleWheel").is_in_contact() and  get_node("VehicleWheel2").is_in_contact()
		and  get_node("VehicleWheel3").is_in_contact() and  get_node("VehicleWheel4").is_in_contact()):
		airborne = true;
	else:
		airborne = false;
		
	var distance_to_player = transform.origin.distance_to(Globals.player_pos)
	
	var wheel_radius = get_node("VehicleWheel").wheel_radius
	var local_velocity = get_transform().basis.z.dot(linear_velocity)

	kph = abs(local_velocity * 3.6);

	var omega = local_velocity / wheel_radius * 6.28;
	var rpm = abs(omega) * abs(gear_ratios[current_gear]) * differential_ratio * (60.0 / 6.28)


	if rpm < torque_curve_rpms[0]:
		rpm = torque_curve_rpms[0]
	if rpm > torque_curve_rpms[5]:
		rpm = torque_curve_rpms[5]

	if (current_gear == 1 and omega <= 1.0 and omega >= 0 and brake > 0):
		current_gear = 0;
	
	if Globals.ai_smartness > 2:
		var follow_player = true
		var change_enemy = false
		var curr_target = null
		var new_target = null
		var go_reverse = false
		if ray.is_enabled() and ray.is_colliding():
			var collObj = ray.get_collider()
			if collObj.name in ['Big Box', 'Kicker', 'Dumpster', 'Tunnel', 'Ring', 'Super Jump', 'Simple Jump', 'Simple Jump2', 'Simple Jump3', "Loop", "Tunnel Ramp"]:
				# print(collObj.name)
				go_reverse = true
			else:
				var temp_groups = collObj.get_groups()
				if 'player' in temp_groups:
					# print('Saw player')
					if not follow_player and floor(rand_range(0,2)):
						follow_player = true
						change_enemy = false
				elif 'enemy' in temp_groups:
					if Globals.ai_smartness == 5:
						if not follow_player and floor(rand_range(0,2)):
							change_enemy = true
							new_target = collObj
						elif follow_player and floor(rand_range(0,4)) < 1:
							follow_player = false
							change_enemy = true
							new_target = collObj
					elif Globals.ai_smartness == 4:
						if not follow_player and floor(rand_range(0,2)):
							change_enemy = true
							new_target = collObj
						elif follow_player and floor(rand_range(0,2)):
							follow_player = false
							change_enemy = true
							new_target = collObj
					else:
						if not follow_player:
							change_enemy = true
							new_target = collObj
						else:
							follow_player = false
							change_enemy = true
							new_target = collObj
						
		if true:
			if enem_follow > 20000 and Globals.ai_smartness > 3: # If enemy is following enemies for 20 secs.
				follow_player = true
			if follow_player:
				enem_follow = 0
				# print('chasing player')
				curr_target = Globals.player_pos
			else:
				enem_follow += 1
				# print('Chasing enemy')
				if change_enemy:
					curr_target = new_target.global_transform.origin;
					change_enemy = false
		if go_reverse:
			if 'enemy1' in groups_list:
				if floor(rand_range(0,2)):  # Random coin flip
					steering_target = -1;
					throttle = -0.6;
				else:
					steering_target = 1
					throttle = -0.6
			elif 'enemy2' in groups_list:
				if floor(rand_range(0,2)):  # Random coin flip
					steering_target = -1;
					throttle = -0.4;
				else:
					steering_target = 1
					throttle = -0.4
		else:
			var dirToMovePosition = curr_target - transform.origin
			var dot = get_global_transform().basis.z.dot(dirToMovePosition)
			var angleToDir = get_global_transform().basis.z.signed_angle_to(dirToMovePosition, Vector3.UP)
			if "enemy1" in groups_list:
				if dot > 0:
					throttle = 0.8;
				else:
					if floor(rand_range(0,2)):  # Random coin flip
						steering_target = -1;
						throttle = 0.6;
					else:
						steering_target = 1;
						throttle = 0.6;
			elif "enemy2" in groups_list:
				if dot > 0:
					throttle = 0.6;
				else:
					if floor(rand_range(0,2)):  # Random coin flip
						steering_target = -1;
						throttle = 0.4;
					else:
						steering_target = 1;
						throttle = 0.4;

			if angleToDir > -0.15 and angleToDir < 0.15:
				steering_target = 0;
			elif angleToDir > 0.15:
				steering_target = 1;
			else:
				steering_target = -1;
	else:
		target = Globals.player_pos
		var dirToMovePosition = target - transform.origin
		var dot = get_global_transform().basis.z.dot(dirToMovePosition)
		var angleToDir = get_global_transform().basis.z.signed_angle_to(dirToMovePosition, Vector3.UP)
		if true:
			if dot > 0:
				throttle = 0.7;
			else:
				throttle = -0.7;
			
			if Globals.ai_smartness == 2:
				if angleToDir > -0.15 and angleToDir < 0.15:
					steering_target = 0;
				elif angleToDir > 0.15:
					steering_target = 1;
				else:
					steering_target = -1;
			else:
				if angleToDir > 0:
					steering_target = 1;
				else:
					steering_target = -1;
	
	
	if current_gear == 0:
		if throttle != 0:
			current_gear = 1
		elif brake > 0:
			throttle = 1
			brake = 0

	if (current_gear > 1):
		if rpm < torque_curve_rpms[1] * 0.5:
			current_gear -= 1
	else:
		pass


	if current_gear > 0 and rpm > torque_curve_rpms[4] and current_gear < 5:
		current_gear += 1

	var high = 0
	while (rpm >= torque_curve_rpms[high]):
		high += 1
		if high >= 6:
			high = 5
			break
	var low = high - 1
	if (high == 0):
		low = 0
		high = 1

	var interp = (rpm - torque_curve_rpms[low]) / (torque_curve_rpms[high] - torque_curve_rpms[low])
	var engine_torque = torque_curve_torques[low] + ((torque_curve_torques[high] - torque_curve_torques[low]) * interp)
	var wheel_torque = throttle * engine_torque * gear_ratios[current_gear] * differential_ratio * transmission_efficiency

	engine_force = wheel_torque * wheel_radius * 2

	if not drifting and Globals.kph > slip_speed:
		drifting = true
	if drifting and Globals.kph < slip_speed and steering_angle == 0:
		drifting = false
	# get_node("VehicleWheel").traction = traction_fast if drifting else traction_slow
	# get_node("VehicleWheel2").traction = traction_fast if drifting else traction_slow
	# velocity = lerp(velocity, new_heading * velocity.length(), traction)		
	wheel_contact = 0
	if get_node("VehicleWheel").is_in_contact():
		wheel_contact += 1
	if get_node("VehicleWheel2").is_in_contact():
		wheel_contact += 1
	if get_node("VehicleWheel3").is_in_contact():
		wheel_contact += 1
	if get_node("VehicleWheel4").is_in_contact():
		wheel_contact += 1
	if wheel_contact < 3:
		num_frame += 1
	else: 
		num_frame = 0
		
	steering_angle += steering_speed * steering_target * delta

	#re-center if not steering
	if not steering_target:
		if steering_angle > 0:
			steering_angle -= steering_speed * delta
			if steering_angle < 0:
				steering_angle = 0
		else:
			steering_angle += steering_speed * delta
			if steering_angle > 0:
				steering_angle = 0

	#calculate the new max steering angle based on velocity data
	var max_steer = steering_max_angle

	if kph < steering_from_speed:
		pass 
	elif kph > steering_to_speed:
		#going faster than highest speed, so remove completely!
		max_steer -= max_steer * steering_percent_drop

	else:
		var steer_delta = (kph - steering_from_speed) / steering_speed_range
		max_steer -= max_steer * steering_percent_drop * steer_delta
#
	if steering_angle > max_steer:
		steering_angle = max_steer
	elif steering_angle < -max_steer:
		steering_angle = -max_steer

	steering = steering_angle


		
func get_target_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	curr_path_index = 0

func update_healthbar(curr_health, max_health):
	$Healthbar3D.update(curr_health, max_health)

func _on_VehicleBody_body_entered(body):
	var text = floating_text.instance()
	
	if body.is_in_group('player') and despawn == false:
		if abs(kph) > abs(Globals.kph):	#enemy is moving faster than player
			if !Globals.shield_active:
				Globals.player_health -= abs(kph) * 0.3
				
			var enemydamage = abs(Globals.kph) * 0.1
			health -= enemydamage
			text.amount = enemydamage
			add_child(text)
			update_healthbar(health, max_health)
		
		else:
			var enemydamage = abs(Globals.kph) * 0.3
			health -= enemydamage
			text.amount = enemydamage
			add_child(text)
			
			if health <= 0:
				Globals.score += 500
				
			update_healthbar(health, max_health)
			Globals.score += enemydamage * 8
			if !Globals.shield_active:
				Globals.player_health -= abs(kph) * 0.1
			

		#if get_node("Crash").is_playing():
			#$Crash.stream_paused = false
		#else:
		#$Crash.play()
	elif body.is_in_group("enemy"):
		var enemydamage =  abs(kph)*0.3
		health -= enemydamage
		
		update_healthbar(health, max_health)
		
#	else:
#		if body.is_in_group("static"):
#			print("need help")			
			
	return


