package f2d.components;

import f2d.components.Component;
import f2d.manager.Mouse;

class OnClick extends Component
{	
	var callback:Void->Void;

	public function new(callback:Void->Void)
	{
		super();
		
		this.callback = callback;
	}	

	override public function update()
	{
		if (Mouse.isPressed() && object.pointInside(Mouse.x, Mouse.y))
			callback();
	}
}
