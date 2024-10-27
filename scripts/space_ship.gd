extends RigidBody3D


# properties
@export_range(0, 10000, 100) var thrust: float = 3000
@export_range(0, 100, 2) var linear_max_speed: float = 10
@export_range(0, 250000, 5000) var rotational_torque: float = 100000
@export var laser_scene: PackedScene
@export_range(0, 0.2, 0.005) var gun_spread: float = 0.015

var prev_velocity: Vector3 = Vector3(.0, .0, .0)


# update movement based on inputs
func _physics_process(delta):
	
	$LightThrusterCenter.light_energy = 0.6
	$LightThrusterRight.light_energy = 0.4
	$LightThrusterLeft.light_energy = 0.4
	
	# apply linear acceleration
	if Input.is_action_pressed("accelerate"):
		if linear_velocity.length() < linear_max_speed:
			var direction = basis * Vector3.BACK
			apply_central_force(direction * thrust)
		$LightThrusterCenter.light_energy = 3.0
		$LightThrusterRight.light_energy = 2.0
		$LightThrusterLeft.light_energy = 2.0
	
	# get rotation inputs
	var rotation_axis = Vector3(
		-1 if Input.is_action_pressed("tilt_up") else 1 if Input.is_action_pressed("tilt_down") else 0,
		1 if Input.is_action_pressed("yaw_left") else -1 if Input.is_action_pressed("yaw_right") else 0,
		-1 if Input.is_action_pressed("roll_left") else 1 if Input.is_action_pressed("roll_right") else 0
	)
	
	# apply rotation
	if rotation_axis != Vector3.ZERO:
		apply_torque(basis * rotation_axis * rotational_torque)
	
	# activate gun timer
	if Input.is_action_just_pressed("shoot"):
		$Gun/FiringTimer.start()
	
	# deactivate gun timer
	if Input.is_action_just_released("shoot"):
		$Gun/FiringTimer.stop()
	
	
	if Input.is_action_pressed("accelerate"):
		var acceleration = (prev_velocity - linear_velocity).length() / delta
		$CustomCamera.trauma_baseline(acceleration * .05)
	prev_velocity = linear_velocity


# fire single shot
func _on_firing_timer_timeout():
	# create a new instance of the laser scene
	var laser = laser_scene.instantiate()
	
	# initialize laser to spawn point position and facing forward from the ship
	var dir = basis * Vector3.BACK + Vector3(randf()-.5, randf()-.5, randf()-.5) * gun_spread
	laser.initialize($Gun/SpawnPoint.global_position, linear_velocity, dir.normalized())
	
	# spawn it into the scene independently
	get_tree().root.add_child(laser)
	
	$CustomCamera.add_trauma(0.3)
