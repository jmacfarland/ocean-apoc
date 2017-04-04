package;

import Item;
import Waypoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton; //IDEA add a restart button below gameover text
import flixel.util.FlxColor;
import flixel.group.FlxGroup;

/********************************
*	@author jmacfarland	*
********************************/

class PlayState extends FlxState
{
	//player vars
	private var player:FlxSprite;
	private var playerSpeed:Float = 1.0;
	private var playerSize:Int = 10;
	private var waypointX:Float;
	private var waypointY:Float;
	private var playerHealth = 100;

	//inventory vars
	private var inventory:FlxTypedGroup<Item>;
	private var items:FlxTypedGroup<Item>;
	private var itemQuantityTexts:FlxTypedGroup<FlxText>;
	private var invBG:FlxSprite;

	//player waypoint vars
	private var numWaypoints:Int = 15;
	private var waypoints:FlxTypedGroup<Waypoint>;
	private var waypointPool:FlxTypedGroup<Waypoint>;

	//obstacle vars
	private var obstacleGroup:FlxGroup;
	private var maxObstaclesPerGroup:Int = 15;
	private var numObstacles:Int = 20;
	private var obstacleMinSize:Int = 15;
	private var obstacleMaxSize:Int = 40;

	//general vars
	private var isFrozen:Bool = false;
	private var solid:FlxGroup;//Group of all things that can be hit
	private var healthText:FlxText;
	private var screenMiddleX:Int = Math.floor(FlxG.width / 2);
	private var screenMiddleY:Int = Math.floor(FlxG.height / 2);
	private var spawnBuffer:Int = 10;

	//grouping
	private var foreground:FlxGroup;
	private var background:FlxGroup;
	private var gui:FlxGroup;
	private var inv:FlxGroup;
	private var midground:FlxGroup; //between foreground and background, and behind player. Obstacles

	override public function create():Void
	{
		super.create();

		//init groups and sorting layers
		solid = new FlxGroup();
		obstacleGroup = new FlxGroup();
		gui = new FlxGroup();//holds any HUD gui items like buttons, healthtext, etc.
		foreground = new FlxGroup();
		midground = new FlxGroup();
		background = new FlxGroup();
		inv = new FlxGroup();

		//create the player object
		player = new FlxSprite(screenMiddleX, screenMiddleY);
		player.makeGraphic(playerSize, playerSize, FlxColor.WHITE);

		//set up visual inventory background thing
		invBG = new FlxSprite(2, FlxG.height - 22);
        invBG.makeGraphic(FlxG.width - 4, 20, 0xFF565656);
		inv.add(invBG);

		//set up inventory and items system
		items = new FlxTypedGroup<Item>();//holds all possible items
		setupItems();
		inventory = new FlxTypedGroup<Item>();//holds anything that is currently in the player's inventory
		itemQuantityTexts = new FlxTypedGroup<FlxText>();
		inv.add(inventory);

		//create the waypoint at the player location
		waypointPool = new FlxTypedGroup<Waypoint>();
		for(i in 0...numWaypoints)
		{
			var temp:Waypoint = new Waypoint(-1, -1);
			temp.exists = false;
			waypointPool.add(temp);
		}

		waypoints = new FlxTypedGroup<Waypoint>();
		waypoints.add(getWaypoint(player.x, player.y));

		//populate the obstacleGroup
		for(i in 0...numObstacles)
		{
			addObstacle();
		}

		healthText = new FlxText(0, 0, 200, "Health: " + playerHealth);
		gui.add(healthText);

		solid.add(obstacleGroup);

		//add the sorting layers
		add(background);
		add(midground);
		add(player);
		add(foreground);
		add(gui);
		add(inv);
		add(itemQuantityTexts);//should sort over top of the inventory
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		//game will only update when not frozen. Place all movement and update-y
		//code in this if block.
		if(!isFrozen)
		{
			//set a new waypoint
			if(FlxG.mouse.justPressed)//set waypoint
			{
				waypoints.add(getWaypoint(FlxG.mouse.x, FlxG.mouse.y));
			}
			else if(FlxG.mouse.pressedRight)//follow mouse
			{
				resetWaypoint(true);
				waypoints.add(getWaypoint(FlxG.mouse.x, FlxG.mouse.y));
			}

			movePlayer();

			//check for collisions
			FlxG.collide(player, solid);
		}
	}

	//Sets up the item system by adding all possible items to a group
	//from which they can be chosen and added to the inventory
	private function setupItems():Void
    {
        //set up all the items
		var buoy = new Item("Buoy");
		buoy.loadGraphic("assets/images/icon_buoy.png");
        items.add(buoy);

		var string = new Item("String");
		string.loadGraphic("assets/images/icon_string.png");
		items.add(string);
    }

	//updates the x and y positions of the inventory items and quantity texts, sorting by
	//relative position in the inventory group ONLY
	private function updateInv():Void
	{
		for(i in 0...inventory.length)
		{
			inventory.members[i].x = 17 * i + 2;
			inventory.members[i].y = FlxG.height - 19;

			//updates the quantity text of the individual item
			itemQuantityTexts.members[i].text = "" + inventory.members[i].quantity;
		}

		//updates the positions of all quantity texts
		for(i in 0...itemQuantityTexts.length)
		{
			itemQuantityTexts.members[i].x = 17 * i + 5;
			itemQuantityTexts.members[i].y = FlxG.height - 13;
		}
	}

	//Checks to see if item of given name exists in the items group, and if so,
	//either adds a new instance of the item if it does not already exist in the inventory,
	//or increments the item quantity if it does already exist
	private function addItem(name:String):Void
    {
        var newItem:Item = new Item(null);

        for(i in 0...items.length)
        {
            if(items.members[i].name == name)
            {
                newItem = items.members[i];
            }
        }

		if(newItem.name == null) return;

		for(item in inventory)
		{
			if(newItem.name == item.name)
			{
				item.quantity++;
				updateInv();//reload the changes
				return;
			}
		}

		//add new FlxText quantity representation for the item. If the code reaches here,
		//the item did not previously exist so its quantity text did not previously exist
		//so we must create a new quantity text.
		var quantityText = new FlxText(newItem.quantity);
		quantityText.color = FlxColor.BLACK;
		quantityText.size = 8;
		itemQuantityTexts.add(quantityText);

        inventory.add(newItem);
        updateInv();
    }

	//Checks through inventory group to see if item of given name exists, and if so,
	//either removes the item if its quantity is 1, or decrements the quantity if quantity > 1
	private function removeItem(name:String):Void
    {
        for(i in 0...inventory.length)
        {
            if(inventory.members[i].name == name)
            {
				if(inventory.members[i].quantity > 1)
				{
					inventory.members[i].quantity--;
					updateInv();
					break;
				}
				else{
                	inventory.remove(inventory.members[i]);
					itemQuantityTexts.remove(itemQuantityTexts.members[i]);//also remove the associated text
					updateInv();
                	break;//only removes first instance found
				}
            }
        }
    }

	private function getWaypoint(x:Float, y:Float):Waypoint
	{
		var temp:Waypoint;
		temp = waypointPool.getFirstAvailable();
		temp.exists = true;
		temp.x = x;
		temp.y = y;
		return temp;
	}

	private function resetWaypoint(all:Bool):Void
	{
		if(all)
		{
			for(temp in waypoints)
			{
				temp.exists = false;
				waypointPool.add(waypoints.remove(temp, true));
			}
		}
		else
		{
			waypoints.members[0].exists = false;
			waypointPool.add(waypoints.remove(waypoints.members[0], true));
		}

		if(waypoints.length == 0)
		{ //if no more waypoints, make a new one at the player location
			waypoints.add(getWaypoint(player.x + playerSize / 2, player.y + playerSize / 2));
		}
	}

	//Moves the player towards the first waypoint
	private function movePlayer():Void
	{
		//setup direction
		var deltaX:Float = waypoints.members[0].x - player.x - playerSize / 2;
 		var deltaY:Float = waypoints.members[0].y - player.y - playerSize / 2;
		var distance:Float = Math.sqrt(Math.pow(deltaX, 2) + Math.pow(deltaY, 2));

		 //only moves if distance is greater than 1. This prevents the visual stutter once the player has arrived at
		 //its destination coordinates.
		if(distance >= 1)
		{
			var ux:Float = deltaX / distance;
			var uy:Float = deltaY / distance;
			player.x += ux * playerSpeed;
			player.y += uy * playerSpeed;
		}
		else
		{
			resetWaypoint(false);
		}
	}

	//Changes the health text to read whatever was passed as an argument
	private function updateHealthText(NewText:String):Void
	{
		healthText.text = NewText;
	}

	//Adds an obstacle of random size and random position, as long as that position
	//does not encroach on the spawn buffer around the center of the screen (player spawn)
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

		//obstacles should be drawn behind the player, but in front of the background (will eventually be water)
		midground.add(obstacle);
	}
}
