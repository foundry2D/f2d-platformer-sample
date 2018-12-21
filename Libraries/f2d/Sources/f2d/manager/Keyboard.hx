package f2d.manager;

import kha.input.KeyCode;

class Keyboard extends Manager
{
	static var keysPressed:Map<KeyCode, Bool>;
	static var keysHeld:Map<KeyCode, Bool>;
	static var keysUp:Map<KeyCode, Bool>;
	static var keysCount:Int = 0;
	static var keysJustPressed:Bool = false;	

	public function new():Void
	{
		super();

		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp);

		keysPressed = new Map<KeyCode, Bool>();
		keysHeld = new Map<KeyCode, Bool>();
		keysUp = new Map<KeyCode, Bool>();		
	}

	override public function update():Void
	{
		for (key in keysPressed.keys())
			keysPressed.remove(key);

		for (key in keysUp.keys())
			keysUp.remove(key);

		keysJustPressed = false;
	}

	override public function reset():Void
	{
		super.reset();

		for (key in keysPressed.keys())
			keysPressed.remove(key);

		for (key in keysHeld.keys())
			keysHeld.remove(key);

		for (key in keysUp.keys())
			keysUp.remove(key);
	}

	function onKeyDown(key:KeyCode):Void
	{
		keysPressed.set(key, true);
		keysHeld.set(key, true);				            									        		

		keysCount++;
		keysJustPressed = true;
	}

	function onKeyUp(key:KeyCode):Void
	{		
		keysUp.set(key, true);
		keysHeld.set(key, false);																					

		keysCount--;
	}

	inline public static function isPressed(key:KeyCode):Bool
	{
		return keysPressed.exists(key);
	}

	inline public static function isHeld(key:KeyCode):Bool
	{
		return keysHeld.get(key);
	}

	inline public static function isUp(key:KeyCode):Bool
	{
		return keysUp.exists(key);
	}

	inline public static function isAnyHeld():Bool
	{
		return (keysCount > 0);
	}

	inline public static function isAnyPressed():Bool
	{
		return keysJustPressed;
	}
}
