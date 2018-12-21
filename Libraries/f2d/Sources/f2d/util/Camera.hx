package f2d.util;

class Camera
{
    public var x:Float;
    public var y:Float;
    
    public var width:Int;
    public var height:Int;
    public var halfWidth:Int;
    public var halfHeight:Int;
    
    public var dzLeft:Int;
    public var dzRight:Int;
    public var dzTop:Int;
    public var dzBottom:Int;

    var screen:Screen;
    
    public function new(screen:Screen):Void
    {
        x = 0;
        y = 0;
        this.screen = screen;
        
        width = Sdg.gameWidth;
        height = Sdg.gameHeight;
        halfWidth = Std.int(width / 2);
        halfHeight = Std.int(height / 2);
        
        dzLeft = 0;
        dzRight = 0;
        dzTop = 0;
        dzBottom = 0;
    }
    
    public function setSize(width:Int, height:Int):Void
    {
        this.width = width;
        this.height = height;
        halfWidth = Std.int(width / 2);
        halfHeight = Std.int(height / 2);
    }
    
    public function setDeadZones(left:Int, right:Int, top:Int, bottom:Int):Void
    {
        dzLeft = left;
        dzRight = right;
        dzTop = top;
        dzBottom = bottom;
    }
    
    public function follow(objX:Float, objY:Float):Void
    {
        if (objX > dzLeft && objX < (screen.worldWidth - dzRight))
            x = objX - halfWidth;
            
        if (objY > dzTop && objY < (screen.worldHeight - dzBottom))
            y = objY - halfHeight;

        checkBoundaries();
    }
        
    public function center(objX:Float, objY:Float):Void
    {
        x = objX - halfWidth;
        y = objY - halfHeight;

        checkBoundaries();        
    }

    function checkBoundaries():Void
    {
        if (x < 0)
            x = 0;
        else if (x + width > screen.worldWidth)
            x = screen.worldWidth - width;
        
        if (y < 0)
            y = 0;
        else if (y + height > screen.worldHeight)
            y = screen.worldHeight - height;
    }
    
    public function moveBy(stepX:Float, stepY:Float):Void
    {
        if (stepX < 0)
        {
            if ((x + stepX) > 0)
                x += stepX;
            else
                x = 0;
        }
        else
        {
            if ((x + Sdg.gameWidth + stepX) < width)
                x += stepX;
            else
                x = width - Sdg.gameWidth;
        }
        
        if (stepY < 0)
        {
            if ((y + stepY) > 0)
                y += stepY;
            else
                y = 0;
        }
        else
        {
            if ((y + Sdg.gameHeight + stepY) < height)
                y += stepY;
            else
                y = height - Sdg.gameHeight;
        }
    }
}
