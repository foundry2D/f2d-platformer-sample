package f2d.manager;

#if Delta
import tween.Delta;

class TweenDelta extends Manager
{		
	public function new():Void
	{
		super();		
	}
	
	override public function update():Void 
	{		
		// Update the tween engine with a delta in seconds
		Delta.step(F2d.fixedDt);
	}
}
#end
