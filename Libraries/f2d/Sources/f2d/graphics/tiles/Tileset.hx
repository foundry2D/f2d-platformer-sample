package f2d.graphics.tiles;

import kha.Image;
import kha.graphics2.Graphics;
import f2d.atlas.Atlas;
import f2d.atlas.Region;
import f2d.Graphic.ImageType;

class Tileset
{	
	var region:Region;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var widthInTiles:Int;
	public var heightInTiles:Int;	
	
	// temp variables
	var _x:Int;
	var _y:Int;
	
	public function new(source:ImageType, tileWidth:Int, tileHeight:Int):Void
	{
		switch (source.type)
		{
			case First(image):
				this.region = new Region(image, 0, 0, image.width, image.height);
			
			case Second(region):
				this.region = region;

			case Third(regionName):
				this.region = Atlas.getRegion(regionName); 
		}		
						
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
		
		widthInTiles = Std.int(region.w / tileWidth);
		heightInTiles = Std.int(region.h / tileHeight);			
	}	
	
	inline public function render(g:Graphics, index:Int, x:Float, y:Float):Void
	{
		_x = index % widthInTiles;
		_y = Std.int(index / widthInTiles);		
		g.drawScaledSubImage(region.image, region.sx + (_x * tileWidth), region.sy + (_y * tileHeight), tileWidth, tileHeight, x, y, tileWidth, tileHeight);
	}
}
