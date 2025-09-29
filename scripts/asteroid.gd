extends RigidBody3D


# properties
@export var models: Array[PackedScene]
@export_range(0, 100, 2) var linear_impulse: float = 10
@export_range(0, 10000, 200) var rotation_impulse: float = 1000


var health : float
var dir : Vector3 = Vector3.ZERO


func initialize(obj_mass = 0, direction = Vector3.ZERO):
	if obj_mass != 0:
		mass = obj_mass
	health = mass
	dir = direction


func _enter_tree():
	pass 	# select model based on mass


func _ready():
	# linear movement
	if dir == Vector3.ZERO:
		dir = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	apply_central_impulse(dir * linear_impulse)
	
	# rotation
	inertia = Vector3.ONE * 0.4 * mass**(5/3)
	var axis = Vector3(randf(), randf(), randf()).normalized()
	apply_torque_impulse(axis * rotation_impulse * randf())


func hit(damage):
	health -= damage
	print("asteroid hp: ", health)
	if health < 0:
		shatter()


func shatter():
	queue_free()
	if mass > 200:
		var asteroid_scene = load("res://scenes/asteroid.tscn")
		
		var instance1 = asteroid_scene.instantiate()
		instance1.position = self.position
		instance1.initialize(mass / 3)
		get_tree().root.add_child(instance1)
		
		var instance2 = asteroid_scene.instantiate()
		instance2.position = self.position
		instance2.initialize(mass / 3)
		get_tree().root.add_child(instance2)
