package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton; //IDEA add a restart button below gameover text
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

class PlayState extends FlxState
{
	//player vars
	private var player:FlxSprite;
	private var playerSpeed:Float = 1.0;
	private var playerSize:Int = 10;
	private var waypoint:FlxPoint;
	private var playerHealth = 100;

	//obstacle vars
	private var obstacleGroup:FlxSpriteGroup;
	private var maxObstaclesPerGroup:Int = 15;
	private var numObstacles:Int = 20;
	private var obstacleMinSize:Int = 15;
	private var obstacleMaxSize:Int = 40;

	//general vars
	private var solid:FlxGroup;//Group of all things that can be hit
	private var healthText:FlxText;
	private var gameOverText:FlxText;
	private var screenMiddleX:Int = Math.floor(FlxG.width / 2);
	private var screenMiddleY:Int = Math.floor(FlxG.height / 2);
	private var spawnBuffer:Int = 10;

	override public function create():Void
	{
		super.create();
		solid = new FlxGroup();

		//create the player object
		player = new FlxSprite(screenMiddleX, screenMiddleY);
		player.makeGraphic(playerSize, playerSize, FlxColor.WHITE);
		add(player);

		//create the waypoint at the player location
		waypoint = new FlxPoint(screenMiddleX, screenMiddleY);

		//populate the obstacleGroup
		obstacleGroup = new FlxSpriteGroup();
		for(i in 0...numObstacles)
		{
			addObstacle();
		}

		healthText = new FlxText(0, 0, 200, "Health: " + playerHealth);
		add(healthText);

		gameOverText = new FlxText(screenMiddleX - 150, screenMiddleY - 20, 500, "Game Over! [SPACE] => restart", 16);
		gameOverText.alpha = 0;
		add(gameOverText);

		solid.add(player);
		solid.add(obstacleGroup);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Only continue if we're still alive
		if (!player.alive)
		{
			if (FlxG.keys.anyJustReleased([SPACE]))
			{
				FlxG.resetState();
			}
			
			return;
		}

		//set a new waypoint
		if(FlxG.mouse.pressed)
		{
			setWaypoint();
		}

		//move the player (duh)
		movePlayer();

		//check for collisions
		FlxG.collide(player, solid);
	}

	private function setWaypoint():Void
	{
		waypoint.x = FlxG.mouse.x;
		waypoint.y = FlxG.mouse.y;
	}

	private function movePlayer():Void
	{
		//setup direction
		var deltaX:Float = waypoint.x - player.x;
		var deltaY:Float = waypoint.y - player.y;
		var distance:Float = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));
		var ux:Float = deltaX / distance;
		var uy:Float = deltaY / distance;

		player.x += ux * playerSpeed;
		player.y += uy * playerSpeed;
	}

	private function gameOver():Void
	{
		player.alive = false;
		gameOverText.alpha = 100;
	}

	private function updateHealthText(NewText:String):Void
	{
		healthText.text = NewText;
	}

	private function addObstacle():Void
	{
		var size:Int = Math.floor(Math.random()*(obstacleMaxSize - obstacleMinSize) + obstacleMinSize);

		var x:Int = Math.floor(Math.random()*FlxG.width);
		var y:Int = Math.floor(Math.random()*FlxG.height);

		//if obstacle is in the spawn buffer zone move it out
		if(x + spawnBuffer + size / 2 >= screenMiddleX)
		{
			x += spawnBuffer + Math.floor(size / 2);
		}else if(x - spawnBuffer - size / 2 <= screenMiddleX)
		{
			x -= spawnBuffer + Math.floor(size / 2);
		}

		if(y + spawnBuffer + size / 2 >= screenMiddleY)
		{
			y += spawnBuffer + Math.floor(size / 2);
		}else if(y - spawnBuffer - size / 2 <= screenMiddleY)
		{
			y -= spawnBuffer + Math.floor(size / 2);
		}

		var obstacle:FlxSprite = new FlxSprite(x, y);
		obstacle.immovable = true;
		obstacle.makeGraphic(size, size, FlxColor.GRAY);

		//add to the parent group
		obstacleGroup.add(obstacle);
		add(obstacle);
	}
}