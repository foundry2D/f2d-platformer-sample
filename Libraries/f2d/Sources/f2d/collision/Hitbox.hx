package f2d.collision;

import f2d.Object;
import f2d.ds.Either;
import f2d.math.Rectangle;
import f2d.math.Point;

/**
 * Abstract representing either a `String` or a `Array<String>`.
 * Conversion is automatic, no need to use this.
 */
abstract SolidType(Either<String, Array<String>>)
{
	@:dox(hide) public inline function new(e:Either<String, Array<String>>) this = e;
	@:dox(hide) public var type(get,never):Either<String, Array<String>>;
	@:to inline function get_type() return this;
	@:from static function fromLeft(v:String) return new SolidType(Left(v));
	@:from static function fromRight(v:Array<String>) return new SolidType(Right(v));
}

@:allow(f2d.collision.Grid)
class Hitbox
{
	public inline static var HITBOX_MASK:Int = 0;
	public inline static var GRID_MASK:Int = 1;
	
	static var lists:Map<String, List<Hitbox>>;

	public var object:Object;
	public var rect:Rectangle;

	var id:Int;

	// Collision information.
	var _moveX:Float;
	var _moveY:Float;
	
	public function new(object:Object, ?rect:Rectangle, ?listName:String):Void
	{
		this.object = object;

		_moveX = _moveY = 0;
		
		if (rect != null)
			this.rect = rect;
		else		
			this.rect = new Rectangle(0, 0, object.width, object.height);

		id = Hitbox.HITBOX_MASK;

		if (listName != null)
			addToList(listName);				
	}

	public static function init():Void
	{
		lists = new Map<String, List<Hitbox>>();
	}

	public static function emptylist(listName:String):Void
	{
		var list = lists.get(listName);

		if (list != null)
			list.clear();
	}

	public static function deleteList(listName:String):Void
	{
		lists.remove(listName);
	}

	/** 
	 * Adds the object to a collision list. 
	 */	
	public function addToList(listName:String):Void
	{
		var list = lists.get(listName);

		if (list == null)
		{
			list = new List<Hitbox>();
			lists.set(listName, list);
		}		
		
		list.push(this);
	}

	/** 
	 * Removes the object from a collision list. 
	 */	
	public function removeFromList(listName:String):Bool
	{
		var list = lists.get(listName);

		if (list != null)
		{
			list.remove(this);
			
			return true;
		}
		else
			return false;		
	}

	/**
	 * Pushes all objects in the screen of the type into the Array. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	listName	The name of the list to check.
	 * @param	into		The Array to populate.
	 */
	public function objectsFromList(listName:String, into:Array<Object>):Void 
	{		
		var list = lists.get(listName);

		if (list != null)
		{
			var n = into.length;

			for (hitbox in list)
				into[n++] = hitbox.object;
		}				
	}	
	
	/**
	 * Checks for a collision against a collision list.
	 * @param	listName	The name of the list to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	public function collide(listName:String, x:Float, y:Float):Object 
	{
		if (object.screen == null || !object.collidable) 
			return null;

		var hitboxes = lists.get(listName);

		if (hitboxes == null)
			return null;
		
		for (e in hitboxes)
		{
			if (e.object.collidable && e.object != object
				&& collideRect(x, y, e.object.x + e.rect.x, e.object.y + e.rect.y, e.rect.width, e.rect.height))
			{
				if (id == Hitbox.HITBOX_MASK && e.id == Hitbox.HITBOX_MASK)
					return e.object;	
				else if (collideMask(e, x, y))
					return e.object;
			}
		}

		return null;
	}

	/**
	 * Checks if this Object collides with a specific Collision Object.
	 * @param	e		The Object to collide against.
	 * @param	x		Virtual x position to place this Object.
	 * @param	y		Virtual y position to place this Object.
	 * @return	The Object if they overlap, or null if they don't.
	 */
	public function collideWith(e:Hitbox, x:Float, y:Float):Object 
	{
		if (object.collidable && e.object.collidable)
		{
			if (collideRect(x, y, e.object.x + e.rect.x, e.object.y + e.rect.y, e.rect.width, e.rect.height))
			{
				if (id == Hitbox.HITBOX_MASK && e.id == Hitbox.HITBOX_MASK)
					return e.object;
				else if (collideMask(e, x, y))
					return e.object;
			}						
		}
		
		return null;
	}
	
	/**
	 * Checks for collision against multiple collision lists.
	 * @param	listNames	An Array of name of lists to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @return	The first Object collided with, or null if none were collided.
	 */
	public function collideLists(listNames:SolidType, x:Float, y:Float):Object 
	{
		if (object.screen == null) 
			return null;

		switch (listNames.type)
		{
			case Left(s):
				return collide(s, x, y);

			case Right(a):
				var e:Object;

				for (type in a)
				{
					e = collide(type, x, y);
					if (e != null) 
						return e;
				}
		}

		return null;
	}

	function collideMask(e:Hitbox, x:Float, y:Float):Bool
	{
		if (id == Hitbox.HITBOX_MASK)
		{
			if (e.id == Hitbox.GRID_MASK)
			{
				var grid:Grid = cast e;
				return grid.collideHitbox(x, y, this);
			}
		}
		else if (id == Hitbox.GRID_MASK)
		{
			if (e.id == Hitbox.HITBOX_MASK)
				trace('grid colliding with hitbox not implemented');
			else if (e.id == Hitbox.GRID_MASK)
				trace('grid colliding with grid not implemented');
		}				
		
		return false;
	}
	
	/**
	 * Checks if this Object overlaps the specified rectangle.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	rX			X position of the rectangle.
	 * @param	rY			Y position of the rectangle.
	 * @param	rWidth		Width of the rectangle.
	 * @param	rHeight		Height of the rectangle.
	 * @return	If they overlap.
	 */
	public function collideRect(x:Float, y:Float, rX:Float, rY:Float, rWidth:Float, rHeight:Float):Bool 
	{
		if (x + rect.x + rect.width > rX &&
			y + rect.y + rect.height > rY &&
			x + rect.x < rX + rWidth &&
			y + rect.y < rY + rHeight)
			return true;		
		else
			return false;
	}
	
	/**
	 * Checks if this Object overlaps the specified position.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	pX			X position.
	 * @param	pY			Y position.
	 * @return	If the Object intersects with the position.
	 */
	public function collidePoint(x:Float, y:Float, pX:Float, pY:Float):Bool 
	{
		if (pX >= (x + rect.x) &&
			pY >= (y + rect.y) &&
			pX < (x + rect.x + object.width) &&
			pY < (y + rect.y + object.height))
			return true;
		else
			return false;
	}
	
	/**
	 * Populates an array with all collided Entities of a type. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	type		The Object type to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideInto<Obj:Object>(listName:String, x:Float, y:Float, array:Array<Obj>):Void {}
	
	/**
	 * Populates an array with all collided Entities of multiple types. This
	 * function does not empty the array, that responsibility is left to the user.
	 * @param	types		An array of Object types to check for.
	 * @param	x			Virtual x position to place this Object.
	 * @param	y			Virtual y position to place this Object.
	 * @param	array		The Array or Vector object to populate.
	 */
	public function collideTypesInto<Obj:Object>(types:Array<String>, x:Float, y:Float, array:Array<Obj>):Void {}

	/**
	 * Moves the Object by the amount, retaining integer values for its x and y.
	 * @param	x			Horizontal offset.
	 * @param	y			Vertical offset.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveBy(x:Float, y:Float, ?solidType:SolidType, sweep:Bool = false):Void
	{
		_moveX += x;
		_moveY += y;
		x = Math.round(_moveX);
		y = Math.round(_moveY);
		_moveX -= x;
		_moveY -= y;

		if (solidType != null)
		{
			var sign:Int, e:Object;

			if (x != 0)
			{
				if (object.collidable && (sweep || collideLists(solidType, object.x + x, object.y) != null))
				{
					sign = x > 0 ? 1 : -1;

					while (x != 0)
					{
						if ((e = collideLists(solidType, object.x + sign, object.y)) != null)
						{
  							if (object.moveCollideX(e)) 
								break;
							else 
								object.x += sign;
						}
						else						
							object.x += sign;						

						x -= sign;
					}
				}
				else 
					object.x += x;
			}
			if (y != 0)
			{
				if (object.collidable && (sweep || collideLists(solidType, object.x, object.y + y) != null))
				{
					sign = y > 0 ? 1 : -1;

					while (y != 0)
					{
						if ((e = collideLists(solidType, object.x, object.y + sign)) != null)
						{
							if (object.moveCollideY(e)) 
								break;
							else 
								object.y += sign;
						}
						else						
							object.y += sign;						

						y -= sign;
					}
				}
				else 
					object.y += y;
			}
		}
		else
		{
			object.x += x;
			object.y += y;
		}
	}

	/**
	 * Moves the Object to the position, retaining integer values for its x and y.
	 * @param	x			X position.
	 * @param	y			Y position.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public inline function moveTo(x:Float, y:Float, solidType:SolidType = null, sweep:Bool = false)
	{
		moveBy(x - object.x, y - object.y, solidType, sweep);
	}
    
    /**
	 * Moves towards the target position, retaining integer values for its x and y.
	 * @param	x			X target.
	 * @param	y			Y target.
	 * @param	amount		Amount to move.
	 * @param	solidType	An optional collision type to stop flush against upon collision.
	 * @param	sweep		If sweeping should be used (prevents fast-moving objects from going through solidType).
	 */
	public function moveTowards(x:Float, y:Float, amount:Float, solidType:SolidType = null, sweep:Bool = false)
	{
		var point = new Point(x - object.x, y - object.y);
				
		if (point.x * point.x + point.y * point.y > amount * amount)		
			point.normalizeThickness(amount);
		
		moveBy(point.x, point.y, solidType, sweep);
	}

	public function destroy()
	{
		for(i in lists.keys())
		{
			lists[i].remove(this);
		}
	}
}
