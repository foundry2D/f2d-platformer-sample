package f2d.manager;

import kha.input.Mouse;
import kha.math.Vector2;
import kha.System;
import f2d.Sdg;

class Mouse extends Manager
{
	public static var init:Bool = false;	
	/**
	 * x not scaled
	 */
	public static var rawX:Int = 0;
	/**
	 * y not scaled
	 */
	public static var rawY:Int = 0;	
	/**
	 * x scaled to the backbuffer
	 */
	public static var x:Int = 0;
	/**
	 * y scaled to the backbuffer
	 */
	public static var y:Int = 0;
	/**
	 * last x position when a mouse click started, scaled to the backbuffer
	 */
	public static var sx:Int = 0;
	/**
	 * last y position when a mouse click started, scaled to the backbuffer
	 */
	public static var sy:Int = 0;

	/**
	 * delta of x
	 */
	public static var dx:Int = 0;
	/**
	 * delta of y
	 */
	public static var dy:Int = 0;	
	/**
	 * x inside the world (adjusted with the camera)
	 */
	public static var wx:Int = 0;
	/**
	 * y inside the world (adjusted with the camera)
	 */
	public static var wy:Int = 0;

	public static var durationMouseDown:Float = 0;

	static var mouseDownStartTime:Float;

	static var mousePressed:Map<Int, Bool>;
	static var mouseHeld:Map<Int, Bool>;
	static var mouseUp:Map<Int, Bool>;
	static var mouseCount:Int = 0;
	static var mouseJustPressed:Bool = false;

	public function new():Void
	{
		super();

		kha.input.Mouse.get().notify(onMouseStart, onMouseEnd, onMouseMove, onMouseWheel);

		mousePressed = new Map<Int, Bool>();
		mouseHeld = new Map<Int, Bool>();
		mouseUp = new Map<Int, Bool>();

		init = true;
	}

	override public function update():Void
	{
		for (key in mousePressed.keys())
			mousePressed.remove(key);

		for (key in mouseUp.keys())
			mouseUp.remove(key);

		mouseJustPressed = false;
	}

	override public function reset():Void
	{
		super.reset();

		for (key in mousePressed.keys())
			mousePressed.remove(key);

		for (key in mouseHeld.keys())
			mouseHeld.remove(key);

		for (key in mouseUp.keys())
			mouseUp.remove(key);
	}

	function onMouseStart(index:Int, x:Int, y:Int):Void
	{
		updateMouseData(x, y, 0, 0);

		Mouse.sx = Std.int(x * Sdg.gameScale);
		Mouse.sy = Std.int(y * Sdg.gameScale);

		mousePressed.set(index, true);
		mouseHeld.set(index, true);

		mouseCount++;

		mouseJustPressed = true;

		mouseDownStartTime = kha.Scheduler.time();
	}

	function onMouseEnd(index:Int, x:Int, y:Int):Void
	{
		updateMouseData(x, y, 0, 0);

		mouseUp.set(index, true);
		mouseHeld.remove(index);

		mouseCount--;

		durationMouseDown = kha.Scheduler.time() - mouseDownStartTime;
	}

	function onMouseMove(x:Int, y:Int, dx:Int, dy:Int):Void
	{
		updateMouseData(x, y, dx, dy);
	}

	function updateMouseData(x:Int, y:Int, dx:Int, dy:Int):Void
	{
		Mouse.rawX = x;
		Mouse.rawY = y;

		var sysW = System.windowWidth();
		var sysH = System.windowHeight();
		var ratio = Sdg.gameWidth / Sdg.gameHeight;
		var sysRatio = sysW / sysH;

		var effectiveWidth;//the width of the game in the window
		var effectiveHeight;//the height of the game in the window

		if(sysRatio > ratio)
		{
			effectiveWidth = Std.int(sysH * ratio);
			effectiveHeight = sysH;
		}
		else
		{
			effectiveHeight = Std.int(sysW / ratio);
			effectiveWidth = sysW;
		}
		var diff = (sysW - effectiveWidth)/2;

		x = Std.int(x - diff);
		x = Std.int(x/effectiveWidth * Sdg.windowWidth);
		if(x < 0) x = 0;
		if(x > Sdg.windowWidth) x = Sdg.windowWidth;

		diff = (sysH - effectiveHeight)/2;
		y = Std.int(y - diff);
		y = Std.int(y / effectiveHeight  * Sdg.windowHeight);
		if(y < 0) y = 0;
		if(y > Sdg.windowHeight) y = Sdg.windowHeight;

		Mouse.x = Std.int(x / Sdg.gameScale);
		Mouse.y = Std.int(y / Sdg.gameScale);
		Mouse.dx = Std.int(dx / Sdg.gameScale);
		Mouse.dy = Std.int(dy / Sdg.gameScale);
		
		if (Sdg.screen != null)
		{
			Mouse.wx = Std.int((x + Sdg.screen.camera.x) / Sdg.gameScale);
			Mouse.wy = Std.int((y + Sdg.screen.camera.y) / Sdg.gameScale);
		}
	}

	function onMouseWheel(delta:Int):Void
	{
		// TODO
		trace("onMouseWheel : " + delta);
	}

	inline public static function isPressed(index:Int = 0):Bool
	{
		return init && mousePressed.exists(index);
	}

	inline public static function isHeld(index:Int = 0):Bool
	{
		return init && mouseHeld.exists(index);
	}

	inline public static function isUp(index:Int = 0):Bool
	{
		return init && mouseUp.exists(index);
	}

	inline public static function isAnyHeld():Bool
	{
		return init && (mouseCount > 0);
	}

	inline public static function isAnyPressed():Bool
	{
		return init && mouseJustPressed;
	}

	public static function checkSwipe(distance:Int = 30, timeFrom:Float = 0.1, timeUntil:Float = 0.25):Swipe
	{
		var swipeOcurred = (isHeld() && Sdg.distance(Mouse.sx, Mouse.sy, Mouse.x, Mouse.y) > distance
			&& durationMouseDown > timeFrom && durationMouseDown < timeUntil);									

		if (swipeOcurred)
			return new Swipe(new Vector2(Mouse.sx, Mouse.sy), new Vector2(Mouse.x, Mouse.y));
		else
			return null;
	}	
}
