extends RigidBody3D


# properties
@export_range(0, 100, 2) var speed: float = 50


# initialize object at given position and start it moving in the given direction
func initialize(pos, dir):
	look_at_from_position(pos, pos + dir, Vector3.UP)
	linear_velocity = dir * speed


# destroy object once lifetime runs out
func _on_lifetime_timeout():
	queue_free()


# destroy object when it hits another object
func _on_area_3d_body_entered(_body):
	queue_free()
