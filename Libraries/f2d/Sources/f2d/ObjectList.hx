package f2d;

import f2d.Object;
import f2d.Sdg;

class ObjectList
{
	public var x(default, set):Float;
	public var y(default, set):Float;

	public var objects:Array<Object>;

	public var count(get, never):Int;	

	public function new(x:Float, y:Float):Void
	{
		objects = new Array<Object>();

		this.x = x;
		this.y = y;		
	}

	public function add(object:Object):Object
	{
		object.x += x;
		object.y += y;

		objects.push(object);

		return object;
	}

	public function remove(object:Object):Object
	{
		objects.remove(object);

		return object;
	}

	public function addToScreen()
	{		
		if (Sdg.screen != null)
		{
			for (object in objects)			
				Sdg.screen.add(object);			
		}
	}

	public function removeFromScreen()
	{		
		if (Sdg.screen != null)
		{
			for (object in objects)			
				Sdg.screen.remove(object);			
		}
	}

	/**
	 * Call a function on all objects in an ObjectList
	 */
	public function apply(func:(Object->Void)):Void
	{
		for (object in objects)
			func(object);
	}

	function set_x(v:Float):Float
	{
		var diff = v - x;

		for (object in objects) 
			object.x += diff;

		return x = v;
	}

	function set_y(v:Float):Float
	{
		var diff = v - y;

		for (object in objects)
			object.y += diff;

		return y = v;
	}

	inline function get_count():Int
	{
		return objects.length;
	}
}
