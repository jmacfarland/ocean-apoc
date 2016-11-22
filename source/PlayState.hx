package;

import Inventory;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton; //IDEA add a restart button below gameover text
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	//player vars
	private var player:FlxSprite;
	private var playerSpeed:Float = 1.0;
	private var playerSize:Int = 10;
	private var waypointX:Float;
	private var waypointY:Float;
	private var playerHealth = 100;
	private var inventory:Inventory;

	//player waypoint vars
	//TODO: add system to keep track of multiple waypoints

	//obstacle vars
	private var obstacleGroup:FlxGroup;
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
	private var canvas:FlxSprite;
	private var lineStyle:LineStyle = {color: FlxColor.BLUE, thickness:1};

	//grouping
	private var foreground:FlxGroup;
	private var background:FlxGroup;
	private var gui:FlxGroup;
	private var midground:FlxGroup; //between foreground and background, and behind player. Obstacles

	override public function create():Void
	{
		super.create();

		//init groups and sorting layers
		solid = new FlxGroup();
		obstacleGroup = new FlxGroup();
		gui = new FlxGroup();
		foreground = new FlxGroup();
		midground = new FlxGroup();
		background = new FlxGroup();

		//create the player object & inventory
		player = new FlxSprite(screenMiddleX, screenMiddleY);
		player.makeGraphic(playerSize, playerSize, FlxColor.WHITE);
		player.centerOrigin();
		inventory = new Inventory();

		//create the FlxSprite to hold the waypoint line
		canvas = new FlxSprite(0, 0);
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		midground.add(canvas);

		//create the waypoint at the player location
		waypointX = player.x;
		waypointY = player.y;

		//populate the obstacleGroup
		for(i in 0...numObstacles)
		{
			addObstacle();
		}

		healthText = new FlxText(0, 0, 200, "Health: " + playerHealth);
		gui.add(healthText);

		gameOverText = new FlxText(screenMiddleX - 150, screenMiddleY - 20, 500, "Game Over! [SPACE] => restart", 16);
		gameOverText.alpha = 0;
		gui.add(gameOverText);

		solid.add(obstacleGroup);

		//add the sorting layers
		add(background);
		add(midground);
		add(player);
		add(foreground);
		add(gui);
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
		if(FlxG.mouse.justPressed)//set waypoint
		{
			waypointX = FlxG.mouse.x;
			waypointY = FlxG.mouse.y;
		}else if(FlxG.mouse.justPressedRight)//cancel waypoint
		{
			waypointX = player.x;
			waypointY = player.y;
		}

		//clear the canvas
		canvas.fill(FlxColor.TRANSPARENT);

		//move the player (duh)
		movePlayer();

		//check for collisions
		FlxG.collide(player, solid);
	}

	private function movePlayer():Void
	{
		//setup direction
		var deltaX:Float = waypointX - player.x;
 		var deltaY:Float = waypointY - player.y;
		var distance:Float = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));

		 //only moves if distance is greater than 1
		if(distance >= 1)
		{
			canvas.drawLine(player.x + playerSize / 2, player.y + playerSize / 2, waypointX, waypointY, lineStyle);
			var ux:Float = deltaX / distance;
			var uy:Float = deltaY / distance;
			player.x += ux * playerSpeed;
			player.y += uy * playerSpeed;
		}
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
		midground.add(obstacle);
	}
}