using Godot;

public partial class Main : Node
{
	[Export]
	public PackedScene MobScene { get; set; }

	private void _on_mob_timer_timeout()
	{
		// Create a new instance of the Mob scene.
		Mob mob = MobScene.Instantiate<Mob>();

		// Choose a random location on the SpawnPath.
		// We store the reference to the SpawnLocation node.
		var mobSpawnLocation = GetNode<PathFollow3D>("SpawnPath/SpawnLocation");
		// And give it a random offset.
		mobSpawnLocation.ProgressRatio = GD.Randf();

		Vector3 playerPosition = GetNode<Player>("Player").Position;
		mob.Initialize(mobSpawnLocation.Position, playerPosition);

		// Spawn the mob by adding it to the Main scene.
		AddChild(mob);
		
		mob.Squashed += GetNode<ScoreLabel>("UserInterface/ScoreLabel").OnMobSquashed;
	}
	private void _on_player_hit()
	{
		var timer = GetNode<Timer>("MobTimer");
		if (timer == null)
		{
			GD.Print("timer was null"); 
		}
		else
		{
			timer.Stop();
		}
		GetNode<Control>("UserInterface/Retry").Show();

	}
	public override void _Ready()
	{
		GetNode<Control>("UserInterface/Retry").Hide();
	}
	
	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event.IsActionPressed("ui_accept") && GetNode<Control>("UserInterface/Retry").Visible)
		{
		// This restarts the current scene.
			GetTree().ReloadCurrentScene();
		}
	}
}

