package f2d;

import kha.Color;
import kha.Image;
import kha.Canvas;
import kha.FastFloat;
import kha.math.Vector2;
import kha.math.Vector2i;
import f2d.math.Rectangle;
import kha.graphics2.Graphics;
import f2d.atlas.Region;
import f2d.ds.ThreeOptions;

/**
 * Abstract representing either a Image, a Region, or the name of a Region.
 * Conversion is automatic, no need to use this.
 */
abstract ImageType(ThreeOptions<Image, Region, String>)
{
	@:dox(hide) public inline function new(e:ThreeOptions<Image, Region, String>) this = e;
	@:dox(hide) public var type(get, never):ThreeOptions<Image, Region, String>;
	@:to inline function get_type() return this;
	@:from static function fromFirst(v:Image) return new ImageType(First(v));
	@:from static function fromSecond(v:Region) return new ImageType(Second(v));
	@:from static function fromThird(v:String) return new ImageType(Third(v));
}

@:allow(f2d.Object)
class Graphic
{
	/**
	 * X offset
	 */
	public var x:Float;
	/** 
	 * Y offset
	 */
	public var y:Float;
	/** 
	 * Tint color 
	 */
	public var color:Color;	
	/**
	 * If the graphic should render
	 */
	public var visible:Bool;
	/**
	 * Alpha amount
	 */
	public var alpha:Float;
	/**
	 * The angle of the rotation in radians 
	 */
	public var angle:FastFloat;	
	/**
	 * The pivot point of the rotation 
	 */
	public var pivot:Vector2;
	/**
	 * The clipping rectangle
	 */
	var clipping:Rectangle;
	/**
	 * The object this graphic belongs
	 */
	private var object:Object;
	
	public function new() 
	{
		x = 0;
		y = 0;
		color = Color.White;
		visible = true;
		alpha = 1;
		angle = 0;		
		pivot = new Vector2();
		clipping = null;
	}
	
	/**
	 * Override this, called when this graphic is added to a object
	 */
	function added():Void {}
	
	/**
	 * Override this, used to add update logic to the graphic
	 */
	public function update():Void {}	 
	 
	inline function preRender(g2:Graphics, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		enableClipping(g2);
			
		if (angle != 0)
			g2.pushRotation(angle, objectX + x + pivot.x - cameraX, objectY + y + pivot.y - cameraY);		
			
		if (alpha != 1) 
			g2.pushOpacity(alpha);
	}

	inline function postRender(g2:Graphics):Void
	{
		if (alpha != 1)
			g2.popOpacity();
			
		if (angle != 0)
			g2.popTransformation();

		disableClipping(g2);
	}
		 
	function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void {}

	inline public function renderTo(canvas:Canvas, x:Float, y:Float):Void
	{
		render(canvas, x, y, 0, 0);
	}

	inline function enableClipping(g2:Graphics):Void
    {
        if (clipping != null)
            g2.scissor(Std.int(object.x + clipping.x), Std.int(object.y + clipping.y), Std.int(clipping.width), Std.int(clipping.height));
    }
    
    inline function disableClipping(g2:Graphics):Void
    {
        if (clipping != null)
            g2.disableScissor();
    }

	/**
	 * Sets the area of the clipping rectangle
	 */
	public function setClipping(x:Float, y:Float, width:Float, height:Float):Void
	{
		if (clipping == null)
			clipping = new Rectangle(this.x + x, this.y + y, width, height);
		else
		{
			clipping.x = this.x + x;
			clipping.y = this.y + y;
			clipping.width = width;
			clipping.height = height;
		}
	}
	
	/**
	 * Override this in the class that is implementing a type of graphic
	 * and return the size of the graphic
	 */
	public function getSize():Vector2i 
	{
		return null;
	}
	
	public function setPivot(pivotX:Float, pivotY:Float):Void
	{
		pivot.x = pivotX;
		pivot.y = pivotY;
	}
	
	public function destroy():Void {}
}
