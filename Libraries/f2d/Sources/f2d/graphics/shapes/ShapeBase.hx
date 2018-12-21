package f2d.graphics.shapes;

import kha.Color;

class ShapeBase extends Graphic
{        
    public var filled:Bool;
    public var strength:Float;
    
    public function new(color:Color, filled:Bool, strength:Float):Void
    {
        super();
        
        this.color = color;
        this.filled = filled;
        this.strength = strength;
    }
}
