package f2d.manager;

import kha.input.Surface;

class Touch extends Manager
{
	public static var init:Bool = false;
	public static var touches:Map<Int, TouchData>;

	static var touchCount:Int = 0;
	static var touchJustPressed:Bool = false;

	public function new():Void
	{
		super();

		Surface.get().notify(onTouchStart, onTouchEnd, onTouchMove);

		touches = new Map<Int, TouchData>();

		init = true;
	}

	override public function update():Void
	{
		for (key in touches.keys())
		{
			var touch = touches[key];

			// bugfix for safari, otherwise will break everything
			if (touch == null)
				continue;

			if (touch.state == InputState.PRESSED)
			{
				touch.state = InputState.HELD;
			}
			else if (touch.state == InputState.UP)
			{
				touch.state = InputState.NONE;
			}
		}

		touchJustPressed = false;
	}

	override public function reset():Void
	{
		super.reset();

		for (key in touches.keys())
			touches.remove(key);
	}



	function onTouchStart(index:Int, x:Int, y:Int):Void
	{
		// Every time a touch is detected, we assume the player is on
		// mobile, so disable the mouse manager immediately.
		Mouse.init = false;		

		updateTouch(index, x, y);
		touches[index].state = InputState.PRESSED;

		touchCount++;

		touchJustPressed = true;
	}

	function onTouchEnd(index:Int, x:Int, y:Int):Void
	{
		updateTouch(index, x, y);
		touches[index].state = InputState.UP;

		touchCount--;
	}

	function onTouchMove(index:Int, x:Int, y:Int):Void
	{
		updateTouch(index, x, y);		
	}

	inline function updateTouch(index:Int, x:Int, y:Int):Void
	{
		if (touches.exists(index))
		{
			touches[index].rawX = x;
			touches[index].rawY = y;
			touches[index].x = Std.int(x / F2d.gameScale);
			touches[index].y = Std.int(y / F2d.gameScale);
			touches[index].dx = Std.int((x - touches[index].x) / F2d.gameScale);
			touches[index].dy = Std.int((y - touches[index].y) / F2d.gameScale);
		}
		else
		{
			touches.set(index, {
				rawX: x,
				rawY: y,
				x: Std.int(x / F2d.gameScale),
				y: Std.int(y / F2d.gameScale),
				dx: 0,
				dy: 0,
				state: InputState.NONE
			});
		}
	}

	inline public static function isPressed(index:Int = 0):Bool
	{
		return init && (touches.exists(index)) ? touches[index].state == InputState.PRESSED : false;
	}

	inline public static function isHeld(index:Int = 0):Bool
	{
		return init && (touches.exists(index)) ? touches[index].state == InputState.HELD : false;
	}

	inline public static function isUp(index:Int = 0):Bool
	{
		return init && (touches.exists(index)) ? touches[index].state == InputState.UP : false;
	}

	inline public static function isAnyHeld():Bool
	{
		return init && (touchCount > 0);
	}

	inline public static function isAnyPressed():Bool
	{
		return init && touchJustPressed;
	}
}
