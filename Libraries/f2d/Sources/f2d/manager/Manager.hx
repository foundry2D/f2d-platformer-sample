package f2d.manager;

class Manager
{
	public inline static var KEYBOARD:Int = 1;
	public inline static var MOUSE:Int = 2;
	public inline static var TOUCH:Int = 4;
	public inline static var GAMEPAD:Int = 8;
	public inline static var DELTA:Int = 16;

	public var active:Bool = true;
	
	public function new():Void {}
	
	public function update():Void {}
	
	public function reset():Void {}
}
