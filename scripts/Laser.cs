using Godot;
using System;

public partial class Laser : RigidBody3D
{
	// Properties

	[Export(PropertyHint.Range, "10, 100, 2")]
	public float Speed { get; set; } = 30.0f;



	// Initialize object with relevant info

	public void Initialize(Vector3 startPosition, Vector3 direction)
	{
		LookAtFromPosition(startPosition, startPosition + direction, Vector3.Up);
		LinearVelocity = direction * Speed;
	}



	// Lifetime Timer Timeout

	public void OnLifetimeTimeout()
	{
		QueueFree();
	}



	// Body entered into Area3D

	public void OnArea3DBodyEntered(Node3D body)
	{
		QueueFree();
	}
}
