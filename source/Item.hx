package;

import org.flixel.FlxSprite;

/**********************
* @author jmacfarland *
**********************/

public class Item extends FlxSprite
{
    public var image:Class;
    public var name:String;
    public var quantity:Int;

    public function Item(name:String, ?quantity:Int)
    {
        this.name = name;
        if(quantity == null) this.quantity = 1;
    }
}