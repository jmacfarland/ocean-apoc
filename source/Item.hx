package;

import flixel.FlxSprite;

/**********************
* @author jmacfarland *
**********************/

class Item extends FlxSprite
{
    //public var image:FlxSprite;
    public var name:String;
    public var quantity:Int;

    override public function new(name:String, ?quantity:Int)
    {
        super();
        this.name = name;
        if(quantity == null) this.quantity = 1;
    }
}