package;

import flixel.FlxBasic;

class Waypoint extends FlxBasic
{
    public var x:Float;
    public var y:Float;

    override public function new(xNew:Float, yNew:Float):Void
    {
        super();

        x = xNew;
        y = yNew;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}