package;

import flixel.FlxSprite;

class Enemy extends FlxSprite
{
    private var damage:Int = 1;
    private var ux:Float;
    private var uy:Float;

    public var fireCountup = 0;
    public var enemyHealth:Int = 10;

    public function new(x:Float, y:Float)
    {
        super(x, y);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        fireCountup++;
    }

    
}

//code to move enemy and shoot and stuff
/*
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

        */