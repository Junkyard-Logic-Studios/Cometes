using Godot;
using System;

public partial class SpaceShip : CharacterBody3D
{
    // Properties

	[Export(PropertyHint.Range, "0, 10, 0.2")]
    public float LinearAcceleration { get; set; } = 1.0f;
    
    [Export(PropertyHint.Range, "0, 100, 2.0")]
    public float LinearMaxSpeed { get; set; } = 10.0f;

    [Export(PropertyHint.Range, "0, 1, 0.02")]
    public float RotationalSpeed { get; set; } = 0.5f;

    [Export]
    public PackedScene LaserScene { get; set; }



    // Physics Update

    public override void _PhysicsProcess(double delta)
    {
        // apply linear acceleration
        if (Input.IsActionPressed("accelerate"))
        {
            var direction = Basis *
                new Vector3(0f, 0f, LinearAcceleration);
            Velocity += direction * (float)delta;
            Velocity = Velocity.LimitLength(LinearMaxSpeed);
        }

        // get rotation inputs
        var rotationAxis = new Vector3(
                (Input.IsActionPressed("tilt_up")    ? -1f : 0f) +
                (Input.IsActionPressed("tilt_down")  ?  1f : 0f),
                (Input.IsActionPressed("yaw_left")   ?  1f : 0f) +
                (Input.IsActionPressed("yaw_right")  ? -1f : 0f),
                (Input.IsActionPressed("roll_left")  ? -1f : 0f) +
                (Input.IsActionPressed("roll_right") ?  1f : 0f)
            );

        // apply rotation
        if (rotationAxis != Vector3.Zero)
        {
            var prevRotation = Basis.GetRotationQuaternion();

            var addRotation = new Quaternion(
                    prevRotation * rotationAxis.Normalized(), 
                    (float)(delta * Mathf.Pi) * RotationalSpeed
                );
            
            Basis = new Basis(addRotation * prevRotation);
        }

        MoveAndSlide();

        // set gun timer
        if (Input.IsActionJustPressed("shoot"))
            GetNode<Timer>("Gun/FiringTimer").Start();

        if (Input.IsActionJustReleased("shoot"))
            GetNode<Timer>("Gun/FiringTimer").Stop();
    }


    
    // Gun Firing Timer Timeout

    public void OnFiringTimerTimeout()
    {
        var spawn = GetNode<Marker3D>("Gun/SpawnPoint");

        Laser laser = LaserScene.Instantiate<Laser>();
        laser.Initialize(spawn.GlobalPosition, Basis * Vector3.Back);

        // spawn into game independent of ship
        GetTree().Root.AddChild(laser);
    }
}
