package f2d.components;

import f2d.Object;

class Component
{
	public var object:Object;
	
	public var active:Bool = true;
	
	public function new():Void {}
	
	public function init():Void {}
	
	public function update():Void {}
	
	public function destroy():Void	{}
}
