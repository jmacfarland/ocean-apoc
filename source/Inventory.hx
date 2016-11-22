package;

import Item;

class Inventory
{
    private var inventory:Array<Item> = new Array();
	private var items:Array<Item> = new Array();

    //private var numSlots:Int;

    public function new()
    {
        //numSlots = slots;
    }

    public function updateInv():Void
	{
		for(i in 0...inventory.length)
		{
			inventory[i].x = 16 * i;
			inventory[i].y = 44;
		}
	}

    public function add(name:String):Void
    {
        var newItem:Item = new Item(null);
        var itemFound:Bool = false;

        for(i in 0...items.length)
        {
            if(items[i].name == name)
            {
                newItem.name = name;
                itemFound = true;
            }
        }

        if(!itemFound) return;

        inventory.push(newItem);
        updateInv();
    }

    public function rem(name:String)
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