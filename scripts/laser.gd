extends RigidBody3D


# properties
@export_range(0, 200, 4) var speed: float = 100


# initialize laser at given position and start it moving in the given direction
func initialize(pos, vel, dir):
	linear_velocity = vel + dir * speed
	look_at_from_position(pos, pos + linear_velocity, Vector3.UP)
	contact_monitor = true
	max_contacts_reported = 1


# destroy laser once lifetime runs out
func _on_lifetime_timeout():
	queue_free()


# destroy laser when it hits another object
func _on_body_entered(body):
	queue_free()
	if body.has_method("hit"):
		body.hit(400)
