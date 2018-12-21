package f2d.math;

import kha.math.Vector2;

class Point extends Vector2
{
    public function normalizeThickness(thickness:Float):Void 
    {		
		if (x == 0 && y == 0)         			
			return;		
        else 
        {		
			var norm = thickness / Math.sqrt(x * x + y * y);
            
			x *= norm;
			y *= norm;			
		}		
	}
    
    public static function distance(pt1:Point, pt2:Point):Float 
    {		
		var dx = pt1.x - pt2.x;
		var dy = pt1.y - pt2.y;
        
		return Math.sqrt(dx * dx + dy * dy);		
	}
}
