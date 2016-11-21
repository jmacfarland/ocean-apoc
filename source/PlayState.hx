package;

import Projectile;
import Enemy;
import flixel.FlxG;
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
	private var playerDirection = FlxObject.NONE;
	private var playerHealth = 100;

	//obstacle vars
	private var obstacleGroup:FlxSpriteGroup;
	private var maxObstaclesPerGroup:Int = 15;
	private var numObstacles:Int = 20;
	private var obstacleMinSize:Int = 15;
	private var obstacleMaxSize:Int = 40;

	//enemy vars
	private var enemyGroup:FlxSpriteGroup;
	private var numEnemies:Int = 5;
	private var enemyDamage:Int = 1;
	private var enemySpeed:Float = 0.5;
	private var projectileGroup:FlxSpriteGroup;
	private var bulletSize:Int = 2;
	private var shootTimer = 0;
	private var shootInterval = 20;

	//general vars
	private var hittable:FlxGroup;//Group of all things that can be hit
	private var healthText:FlxText;
	private var gameOverText:FlxText;
	private var screenMiddleX:Int = Math.floor(FlxG.width / 2);
	private var screenMiddleY:Int = Math.floor(FlxG.height / 2);
	private var spawnBuffer:Int = 10;

	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		enemyGroup = new FlxSpriteGroup();
		projectileGroup = new FlxSpriteGroup();
		hittable = new FlxGroup();

		//create the player object
		player = new FlxSprite(screenMiddleX - playerSize * 2, screenMiddleY);
		player.makeGraphic(playerSize, playerSize, FlxColor.WHITE);
		add(player);

		//populate the obstacleGroup
		obstacleGroup = new FlxSpriteGroup();
		for(i in 0...numObstacles)
		{
			addObstacle();
		}

		//populate the enemy group
		for(i in 0...numEnemies)
		{
			var x:Int = Math.floor(Math.random()*FlxG.width);
			var y:Int = Math.floor(Math.random()*FlxG.height);
			
			//repeat until x and y are out of the spawn buffer
			while((x + spawnBuffer < screenMiddleX &&
				x - spawnBuffer > screenMiddleX ) &&
				(y + spawnBuffer < screenMiddleY &&
				y - spawnBuffer > screenMiddleY))
			{
				x = Math.floor(Math.random()*FlxG.width);
				y = Math.floor(Math.random()*FlxG.height);
			}

			var enemy:FlxSprite = new FlxSprite(x, y);
			enemy.makeGraphic(playerSize, playerSize, FlxColor.RED);

			enemyGroup.add(enemy);
			add(enemy);
		}

		healthText = new FlxText(0, 0, 200, "Health: " + playerHealth);
		add(healthText);

		gameOverText = new FlxText(screenMiddleX - 150, screenMiddleY - 20, 500, "Game Over! [SPACE] => restart", 16);
		gameOverText.alpha = 0;
		add(gameOverText);

		hittable.add(player);
		hittable.add(enemyGroup);
		hittable.add(obstacleGroup);
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

		if(FlxG.keys.anyPressed([UP, W]))
		{
			playerDirection = FlxObject.UP;
		}
		else if(FlxG.keys.anyPressed([DOWN, S]))
		{
			playerDirection = FlxObject.DOWN;
		}
		else if(FlxG.keys.anyPressed([LEFT, A]))
		{
			playerDirection = FlxObject.LEFT;
		}
		else if(FlxG.keys.anyPressed([RIGHT, D]))
		{
			playerDirection = FlxObject.RIGHT;
		}
		else
		{
			playerDirection = FlxObject.NONE;
		}

		//move enemy
		for(enemy in enemyGroup)
		{
			if(enemy.alive)
			{
				moveEnemy(enemy, player.x, player.y);//takes target x and y

				if(shootTimer >= shootInterval)
				{
					enemyShoot(enemy);
				}
			}
		}

		if(shootTimer >= shootInterval)
		{
			shootTimer = 0;
		}else
		{
			shootTimer++;
		}

		//move the player (duh)
		movePlayer(elapsed);

		//check for collisions
		FlxG.collide(player, obstacleGroup);
		FlxG.collide(player, projectileGroup, playerTakeDamage);
		FlxG.collide(enemyGroup, obstacleGroup);
		FlxG.collide(enemyGroup, projectileGroup, killEnemy);

		//destroy bullets if they hit anything
		FlxG.collide(projectileGroup, hittable, destroyProjectile);
	}

	private function killEnemy(enemy:FlxSprite, projectile:Projectile):Void
	{
		enemy.kill();
		enemy.active = false;
	}

	private function destroyProjectile(projectile:Projectile, hitObject:FlxObject):Void
	{
		projectile.destroy();
	}

	private function moveEnemy(enemy:FlxSprite, targetX:Float, targetY:Float):Void
	{
		var deltaX:Float = targetX - enemy.x;
		var deltaY:Float = targetY - enemy.y;
		var distance:Float = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));
		var ux:Float = deltaX / distance;
		var uy:Float = deltaY / distance;

		enemy.x += ux * enemySpeed;
		enemy.y += uy * enemySpeed;
	}

	private function enemyShoot(enemy:FlxSprite):Void
	{
		//setup direction
		var deltaX:Float = player.x - enemy.x;
		var deltaY:Float = player.y - enemy.y;
		var distance:Float = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));
		var ux:Float = deltaX / distance;
		var uy:Float = deltaY / distance;

		//make a projectile
		var projectile:Projectile = new Projectile(enemy.x + enemy.origin.x, enemy.y + enemy.origin.y);
		projectile.makeGraphic(bulletSize, bulletSize, FlxColor.ORANGE);

		//give it a unit vector of direction
		projectile.ux = ux;
		projectile.uy = uy;

		//add a projectile to a group of projectiles that will update
		projectileGroup.add(projectile);
		add(projectile);
	}

	private function movePlayer(elapsed:Float):Void
	{
		if(player.x < FlxG.width && player.x > 0 && player.y < FlxG.height && player.y > 0)
		{
			switch(playerDirection)
			{
				case FlxObject.LEFT:
					player.x -= playerSpeed;
				case FlxObject.RIGHT:
					player.x += playerSpeed;
				case FlxObject.UP:
					player.y -= playerSpeed;
				case FlxObject.DOWN:
					player.y += playerSpeed;
			}
		//check if player is within bounds & move to within bounds if not
		}else if(player.x >= FlxG.width)
		{
			player.x--;
		}else if(player.x <= 0)
		{
			player.x++;
		}else if(player.y >= FlxG.height)
		{
			player.y--;
		}else if(player.y <= 0)
		{
			player.y++;
		}
	}

	private function playerTakeDamage(player:FlxObject, projectile:FlxObject):Void
	{
		//TODO: make taking damage knock the player back away from the enemy
		playerHealth -= enemyDamage;
		updateHealthText("Health: " + playerHealth);

		if(playerHealth <= 0)
		{
			gameOver();
		}

		projectile.destroy();

		//knockback code (WISHLIST)
		/*
		var deltaX:Float = Object1.x - Object2.x;
		var deltaY:Float = Object1.y - Object2.y;
		var distance:Float = Math.sqrt(Math.pow(deltaX, 2) + Math.sqrt(Math.pow(deltaY, 2)));
		var dx:Float = deltaX / distance;
		var dy:Float = deltaY / distance;
		*/
		
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