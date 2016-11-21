package;

import flixel.FlxSprite;
import flixel.FlxG;

class Projectile extends FlxSprite
{
    public var ux:Float = 0;
    public var uy:Float = 0;
    private var speed:Float = 1.4;

    public function new(x:Float, y:Float)
    {
        super(x, y);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        this.x += ux * speed;
        this.y += uy * speed;
    }
}