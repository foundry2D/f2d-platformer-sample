package f2d.collision;

import f2d.math.Rectangle;

class Grid extends Hitbox
{
	/**
	 * The tile width
	 */
	public var tileWidth(default, null):Int;		
	/**
	 * The tile height
	 */
	public var tileHeight(default, null):Int;	
	/**
	 * How many columns the grid has
	 */
	public var columns(default, null):Int;
	/**
	 * How many rows the grid has
	 */
	public var rows(default, null):Int;
	/**
	 * The grid data
	 */
	public var data(default, null):Array<Array<Tile>>;

	public function new(object:Object, tileWidth:Int, tileHeight:Int, ?listName:String):Void
	{
		super(object, null, listName);

		id = Hitbox.GRID_MASK;

		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		// set grid properties
		columns = Std.int(this.rect.width / tileWidth);
		rows = Std.int(this.rect.height / tileHeight);

		data = new Array<Array<Tile>>();

		for (y in 0...rows)
		{
			data.push(new Array<Tile>());

			for (x in 0...columns)
				data[y].push(new Tile(false));
		}
	}

	/**
	 * Sets the value of the tile. Ignores the setting of usePositions, and assumes coordinates are
	 * XY tile coordinates (the usePositions default).
	 * @param	x			Tile column.
	 * @param	y			Tile row.
	 * @param	solid		If the tile should be solid.
	 */
	public function setTile(x:Int, y:Int, solid:Bool = true):Void
	{
		if (!checkTile(x, y)) 
			return;

		data[y][x].solid = solid;
	}

	/**
	 * Makes the tile non-solid.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	inline public function clearTile(x:Int, y:Int):Void
	{
		setTile(x, y, false);
	}

	inline function checkTile(x:Int, y:Int):Bool
	{
		// check that tile is valid
		if (x < 0 || x > columns - 1 || y < 0 || y > rows - 1)		
			return false;		
		else		
			return true;
	}

	/**
	 * Gets the value of a tile. Ignores the setting of usePositions, and assumes coordinates are
	 * XY tile coordinates (the usePositions default).
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	tile value.
	*/
	public function getTile(x:Int, y:Int):Bool
	{
		if (!checkTile(x, y))
			return false;

		return data[y][x].solid;
	}

	/**
	 * Sets the value of a rectangle region of tiles.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 * @param	solid		Value to fill.
	 */
	public function setArea(x:Int, y:Int, width:Int = 1, height:Int = 1, solid:Bool = true):Void
	{
		for (yy in y...(y + height))
		{
			for (xx in x...(x + width))
				setTile(xx, yy, solid);			
		}
	}

	/**
	 * Makes the rectangular region of tiles non-solid.
	 * @param	column		First column.
	 * @param	row			First row.
	 * @param	width		Columns to fill.
	 * @param	height		Rows to fill.
	 */
	public inline function clearArea(x:Int, y:Int, width:Int = 1, height:Int = 1):Void
	{
		setArea(x, y, width, height, false);
	}

	public function setColRect(x:Int, y:Int, rect:Rectangle):Void
	{
		if (!checkTile(x, y))
			return;

		data[y][x].rect = rect;
		data[y][x].solid = rect != null ? true : false;		
	}

	inline public function clearColRect(x:Int, y:Int):Void
	{
		setColRect(x, y, null);
	}

	/**
	* Loads the grid data from a string.
	* @param	str			The string data, which is a set of tile values (0 or 1) separated by the columnSep and rowSep strings.
	* @param	columnSep	The string that separates each tile value on a row, default is ",".
	* @param	rowSep		The string that separates each row of tiles, default is "\n".
	*/
	public function loadFromString(str:String, columnSep:String = ',', rowSep:String = '\n')
	{
		var row:Array<String> = str.split(rowSep);
		var rows:Int = row.length;
		var col:Array<String>, cols:Int, x:Int, y:Int;
			
		for (y in 0...rows)
		{
			if (row[y] == '') 
				continue;

			col = row[y].split(columnSep);
			cols = col.length;

			for (x in 0...cols)
			{
				if (col[x] == '') 
					continue;

				setTile(x, y, Std.parseInt(col[x]) > 0);
			}
		}
	}

	/**
	* Loads the grid data from an array.
	* @param	array	The array data, which is a set of tile values (0 or 1)
	*/
	public function loadFrom2DArray(array:Array<Array<Int>>)
	{
		for (y in 0...array.length)
		{
			for (x in 0...array[y].length)			
				setTile(x, y, array[y][x] > 0);			
		}
	}

	/**
	* Saves the grid data to a string.
	* @param	columnSep	The string that separates each tile value on a row, default is ",".
	* @param	rowSep		The string that separates each row of tiles, default is "\n".
	*
	* @return The string version of the grid.
	*/
	public function saveToString(columnSep:String = ',', rowSep:String = '\n',
		solid:String = 'true', empty:String = 'false'): String
	{
		var s:String = '',
			x:Int, y:Int;

		for (y in 0...rows)
		{
			for (x in 0...columns)
			{
				s += Std.string(getTile(x, y) ? solid : empty);

				if (x != columns - 1) 
					s += columnSep;
			}

			if (y != rows - 1) 
				s += rowSep;
		}

		return s;
	}
	
	public function collideHitbox(hx:Float, hy:Float, hb:Hitbox):Bool
	{
		var tx1 = (hx + hb.rect.x) - (object.x + rect.x);
		var ty1 = (hy + hb.rect.y) - (object.y + rect.y);

		var x2 = Std.int((tx1 + hb.rect.width - 1) / tileWidth) + 1;
		var y2 = Std.int((ty1 + hb.rect.height - 1) / tileHeight) + 1;
		var x1 = Std.int(tx1 / tileWidth);
		var y1 = Std.int(ty1 / tileHeight);

		var tile:Tile;

		for (dy in y1...y2)
		{
			for (dx in x1...x2)
			{
				if (checkTile(dx, dy))
				{
					tile = data[dy][dx];
					
					if (tile.solid)
					{
						if (tile.rect == null)
							return true;
						else if (hb.collideRect(hx, hy, (dx * tileWidth) + tile.rect.x, (dy * tileHeight) + tile.rect.y, tile.rect.width, tile.rect.height))
							return true;
					}
				}								
			}
		}

		return false;
	}	
}
