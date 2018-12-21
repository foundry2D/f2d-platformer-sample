package f2d.graphics;

import kha.Image;
import kha.Canvas;
import kha.math.Vector2i;
import f2d.atlas.Atlas;
import f2d.atlas.Region;
import f2d.Graphic.ImageType;

class NinePatch extends Graphic
{	
	/**
	 * The region inside the image that is rendered
	 */
	public var region:Region;	
	
	var leftBorder:Int;
	var rightBorder:Int;
	var topBorder:Int;
	var bottomBorder:Int;
	
	public var width(default, set):Int;
	public var height(default, set):Int;

	var innerWidth:Int;
	var innerHeight:Int;

	public function new (source:ImageType, leftBorder:Int, rightBorder:Int, topBorder:Int, bottomBorder:Int, width:Int, height:Int):Void
	{
		super();
		
		switch (source.type)
		{
			case First(image):
				this.region = new Region(image, 0, 0, image.width, image.height);
			
			case Second(region):
				this.region = region;

			case Third(regionName):
				this.region = Atlas.getRegion(regionName);
		}		

		this.leftBorder = leftBorder;
		this.rightBorder = rightBorder;
		this.topBorder = topBorder;
		this.bottomBorder = bottomBorder;
		
		this.width = width;
		this.height = height;				
	}	

	override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void
	{
		preRender(canvas.g2, objectX, objectY, cameraX, cameraY);

		canvas.g2.color = color;
		
		if (leftBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx, region.sy + topBorder,	// sxy
				leftBorder, region.h - topBorder - bottomBorder,					// swh
				objectX + x - cameraX, objectY + y + topBorder - cameraY,			// xy
				leftBorder, innerHeight);											// wh
		}

		if (rightBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx + region.w - rightBorder, region.sy + topBorder,
				rightBorder, region.h - topBorder - bottomBorder,
				objectX + x + leftBorder + innerWidth - cameraX, objectY + y + topBorder - cameraY,
				rightBorder, innerHeight);
		}

		if (topBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx + leftBorder, region.sy,
				region.w - leftBorder - rightBorder, topBorder,
				objectX + x + leftBorder - cameraX, object.y + y - cameraY,
				innerWidth, topBorder);
		}

		if (bottomBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx + leftBorder, region.sy + region.h - bottomBorder,
				region.w - leftBorder - rightBorder, bottomBorder,
				objectX + x + leftBorder - cameraX, objectY + y + topBorder + innerHeight - cameraY,
				innerWidth, bottomBorder);
		}

		if (leftBorder > 0 && topBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx, region.sy, 
				leftBorder, topBorder,
				objectX + x - cameraX, objectY + y - cameraY, 
				leftBorder, topBorder);
		}

		if (rightBorder > 0 && topBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx + region.w - rightBorder, region.sy, 
				rightBorder, topBorder,
				objectX + x + leftBorder + innerWidth - cameraX,	objectY + y - cameraY,
				rightBorder, topBorder);
		}

		if (leftBorder > 0 && bottomBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx, region.sy + region.h - bottomBorder,
				leftBorder, bottomBorder,
				objectX + x - cameraX, objectY + y + topBorder + innerHeight - cameraY,
				leftBorder, bottomBorder);
		}

		if (rightBorder > 0 && bottomBorder > 0)
		{
			canvas.g2.drawScaledSubImage(region.image, region.sx + region.w - rightBorder, region.sy + region.h - bottomBorder,
				rightBorder, bottomBorder,
				objectX + x + leftBorder + innerWidth - cameraX, objectY + y + topBorder + innerHeight - cameraY,
				rightBorder, bottomBorder);
		}

		canvas.g2.drawScaledSubImage(region.image, region.sx + leftBorder, region.sy + topBorder,
			region.w - leftBorder - rightBorder, region.h - topBorder - bottomBorder,
			objectX + x + leftBorder - cameraX, objectY + y + topBorder - cameraY,
			innerWidth, innerHeight);

		postRender(canvas.g2);
	}

	inline function set_width(value:Int):Int
	{
		innerWidth = value - leftBorder - rightBorder;

		if (innerWidth < 0)
			innerWidth = 0;

		return (width = value);
	}

	inline function set_height(value:Int):Int
	{
		innerHeight = value - topBorder - bottomBorder;

		if (innerHeight < 0)
			innerHeight = 0;

		return (height = value);
	}

	override public function getSize():Vector2i
	{
		return new Vector2i(width, height);
	}
}
