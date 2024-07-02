extends CharacterBody3D


# properties
@export_range(0, 10, 0.2) var linear_acceleration: float = 1
@export_range(0, 100, 2) var linear_max_speed: float = 10
@export_range(0, 1, 0.02) var rotational_speed: float = 0.5
@export var laser_scene: PackedScene


# update movement based on inputs
func _physics_process(delta):
	# apply linear acceleration
	if Input.is_action_pressed("accelerate"):
		var direction = basis * Vector3.BACK * linear_acceleration
		velocity += direction * delta
		velocity = velocity.limit_length(linear_max_speed)
	
	# get rotation inputs
	var rotation_axis = Vector3(
		-1 if Input.is_action_pressed("tilt_up") else 1 if Input.is_action_pressed("tilt_down") else 0,
		1 if Input.is_action_pressed("yaw_left") else -1 if Input.is_action_pressed("yaw_right") else 0,
		-1 if Input.is_action_pressed("roll_left") else 1 if Input.is_action_pressed("roll_right") else 0
	)
	
	# apply rotation
	if rotation_axis != Vector3.ZERO:
		var prev_rotation = basis.get_rotation_quaternion()
		var add_rotation = Quaternion(
			prev_rotation * rotation_axis.normalized(),
			delta * PI * rotational_speed
		)
		basis = Basis(add_rotation * prev_rotation)
	
	move_and_slide()
	
	# activate gun timer
	if Input.is_action_just_pressed("shoot"):
		$Gun/FiringTimer.start()
	
	# deactivate gun timer
	if Input.is_action_just_released("shoot"):
		$Gun/FiringTimer.stop()


# fire single shot
func _on_firing_timer_timeout():
	# create a new instance of the laser scene
	var laser = laser_scene.instantiate()
	
	# initialize laser to spawn point position and facing forward from the ship
	laser.initialize($Gun/SpawnPoint.global_position, basis * Vector3.BACK)
	
	# spawn it into the scene independently
	get_tree().root.add_child(laser)
