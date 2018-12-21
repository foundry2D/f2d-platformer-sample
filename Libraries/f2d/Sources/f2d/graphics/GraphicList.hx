package f2d.graphics;

import kha.Canvas;
import kha.math.Vector2i;

class GraphicList extends Graphic
{
	public var graphics:Array<Graphic>;

	public function new(graphics:Array<Graphic>):Void
	{
		super();
		
		this.graphics = new Array<Graphic>();

		for (graphic in graphics)
			add(graphic);
	}
	
	override function added():Void 
	{
		for (graphic in graphics)
			graphic.object = object;
	}

	public inline function add(graphic:Graphic):Void
	{
		graphics.push(graphic);
		
		if (object != null)
			graphic.object = object;
	}

	public inline function remove(graphic:Graphic):Void
	{		
		graphics.remove(graphic);
	}

	public inline function removeAt(index:Int):Void
	{		
		graphics.splice(index, 1);
	}

	override public function update()
	{
		for (graphic in graphics)
			graphic.update();		
	}

	override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void
	{
		for (graphic in graphics)
		{
			if (graphic.visible)
				graphic.render(canvas, objectX + x, objectY + y, cameraX, cameraY);
		}
	}
	
	override public function getSize():Vector2i
	{
		var left:Float = 0;
		var right:Float = 0;
		var top:Float = 0;
		var bottom:Float = 0;
		
		for (graphic in graphics)
		{
			var size = graphic.getSize();
			
			if (graphic.x < left)
				left = graphic.x;
			if ((graphic.x + size.x) > right)
				right = graphic.x + size.x;
				
			if (graphic.y < top)
				top = graphic.y;
			if ((graphic.y + size.y) > bottom)
				bottom = graphic.y + size.y;
		}
		
		return new Vector2i(Std.int(right - left), Std.int(bottom - top));
	}

	override public function destroy()
	{
		for (graphic in graphics)		
			graphic.destroy();		
	}
}
