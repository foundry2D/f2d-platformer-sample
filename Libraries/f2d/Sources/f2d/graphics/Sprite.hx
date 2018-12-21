package f2d.graphics;

import kha.Image;
import kha.Canvas;
import kha.math.Vector2i;
import f2d.math.Vector2b;
import f2d.atlas.Atlas;
import f2d.atlas.Region;
import f2d.Graphic.ImageType;

class Sprite extends Graphic
{	
	/**
	 * The region inside the image that is rendered
	 */
	public var region(default, set):Region;
	/**
	 * A shortcut for the width of the region
	 */
	public var width(get, never):Int;
	/**
	 * A shortcut for the height of the region
	 */
	public var height(get, never):Int;
	/**
	 * A scale in x to render the region
	 */
	public var scaleX(default, set):Float;	
	/**
	 * A scale in y to render the region
	 */
	public var scaleY(default, set):Float;
	/**
	 * The width of the region with the scale applied
	 */
	public var widthScaled(default, null):Int;
	/**
	 * The height of the region with the scale applied
	 */		
	public var heightScaled(default, null):Int;
	/**
	 * If the sprite should be rendered flipped
	 */
	public var flip:Vector2b;	
	
	public function new(source:ImageType):Void
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
		
		scaleX = 1;
		scaleY = 1;
		
		flip = new Vector2b();				
	}
	
	override public function destroy():Void
	{		
		region = null;
	}
	
	override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		preRender(canvas.g2, objectX, objectY, cameraX, cameraY);

		canvas.g2.color = color;
			
		canvas.g2.drawScaledSubImage(region.image, region.sx, region.sy, region.w, region.h,
							 objectX + x + (flip.x ? widthScaled : 0) - cameraX,
							 objectY + y + (flip.y ? heightScaled : 0) - cameraY, 
							 flip.x ? -widthScaled : widthScaled, flip.y ? -heightScaled : heightScaled);

		postRender(canvas.g2);		
	}    
	
	public function setScale(value:Float):Void
	{
		scaleX = value;
		scaleY = value;
	}
	
	public function setFlip(flipX:Bool, flipY:Bool):Void
	{
		flip.x = flipX;
		flip.y = flipY;
	}
	
	override public function getSize():Vector2i
	{
		return new Vector2i(widthScaled, heightScaled);
	}
	
	public function set_region(value:Region):Region
	{
		if (value != null)
        {
            widthScaled = Std.int(value.w * scaleX);
		    heightScaled = Std.int(value.h * scaleY);    
        }
        		
		return region = value;
	}

	inline public function get_width():Int
	{
		return region.w;
	}

	inline public function get_height():Int
	{
		return region.h;
	}
		
	public function set_scaleX(value:Float):Float
	{		
		widthScaled = Std.int(region.w * value);
		
		return scaleX = value;
	}	
	
	public function set_scaleY(value:Float):Float
	{
		heightScaled = Std.int(region.h * value);
		
		return scaleY = value;
	}
}
