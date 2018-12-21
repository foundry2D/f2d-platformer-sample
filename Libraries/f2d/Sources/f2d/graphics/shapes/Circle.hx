package f2d.graphics.shapes;

import kha.Color;
import kha.Canvas;
import kha.math.Vector2;
import kha.math.Vector2i;

using kha.graphics2.GraphicsExtension;

class Circle extends ShapeBase
{    
    public var segments:Int;
    public var radius:Float;
    
    public function new(radius:Float, color:Color, filled:Bool = true, strength:Float = 1):Void
    {
        super(color, filled, strength);
        
        this.radius = radius;
        segments = 0;
    }
    
    override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
    {
        preRender(canvas.g2, objectX, objectY, cameraX, cameraY);

        canvas.g2.color = color;
        
        if (filled)
            canvas.g2.fillCircle(objectX + x + radius - cameraX, objectY + y + radius - cameraY, radius, segments);
        else
            canvas.g2.drawCircle(objectX + x + radius - cameraX, objectY + y + radius - cameraY, radius, strength, segments);

        postRender(canvas.g2);
    }
	
	override public function getSize():Vector2i 
    {
		var size = Std.int(radius * 2);
        return new Vector2i(size, size);
    }
}
