package;

import Item;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

class Inventory extends FlxBasic
{
    public var inventory:Array<Item> = new Array();
	private var items:Array<Item> = new Array();

    //private var numSlots:Int;

    public function new()
    {
        super();

        //set up all the items
        items.push(new Item("Buoy"));
        items[0].loadGraphic(AssetPaths.icon_buoy__png);
    }

    public function updateInv():Void
	{
		for(i in 0...inventory.length)
		{
			inventory[i].x = 17 * i;
			inventory[i].y = 2;
		}
	}

    public function addItem(name:String):Void
    {
        var newItem:Item = new Item(null);

        for(i in 0...items.length)
        {
            if(items[i].name == name)
            {
                newItem.name = name;
            }
        }

        inventory.push(newItem);
        updateInv();
        //return(newItem);
    }

    public function removeItem(name:String)
    {
        for(i in 0...inventory.length)
        {
            if(inventory[i].name == name)
            {
                inventory.remove(inventory[i]);
                break;//only removes first instance found
            }
        }
    }
}