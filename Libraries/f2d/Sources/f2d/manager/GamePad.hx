package f2d.manager;

import kha.math.Vector2;

@:allow(f2d.manager.GamePadMan)
class GamePad
{
	static var manager:GamePadMan;

	public static inline var A_X:Int = 0;
	public static inline var B_CIRCLE:Int = 1;
	public static inline var X_SQUARE:Int = 2;
	public static inline var Y_TRIANGLE:Int = 3;
	public static inline var LBL1:Int = 4;
	public static inline var RBR1:Int = 5;
	public static inline var LEFT_ANALOG_PRESS:Int = 6;
	public static inline var RIGHT_ANALOG_PRESS:Int = 7;
	public static inline var START:Int = 8;
	public static inline var BACK_SELECT:Int = 9;
	public static inline var HOME:Int = 10;
	public static inline var DUP:Int = 11;
	public static inline var DDOWN:Int = 12;
	public static inline var DLEFT:Int = 13;
	public static inline var DRIGHT:Int = 14;

	public var id:Int;
	public var active(default, null):Bool;

	public var leftAnalog:Vector2;
	public var rightAnalog:Vector2;
	public var leftTrigger:Float = 0;
	public var rightTrigger:Float = 0;
	
	var buttonsPressed:Map<Int, Bool>;
	var buttonsHeld:Map<Int, Bool>;
	var buttonsUp:Map<Int, Bool>;
	var buttonsCount:Int;
	var buttonsJustPressed:Bool;	
	
	function new(id:Int)
	{
		this.id = id;
		leftAnalog = new Vector2(0, 0);
		rightAnalog = new Vector2(0, 0);
		leftTrigger = 0;
		rightTrigger = 0;
		buttonsPressed = new Map<Int, Bool>();
		buttonsHeld = new Map<Int, Bool>();
		buttonsUp = new Map<Int, Bool>();
		buttonsCount = 0;
		buttonsJustPressed = false;	
	}

	public static function getManager():GamePadMan
	{
		if (manager == null)
			manager = new GamePadMan();

		return manager;
	}

	public static function get(i:Int = 0):GamePad
	{
		return GamePadMan.gamePads.get(i);
	}

	function update():Void
	{
		for (key in buttonsUp.keys())
			buttonsUp.remove(key);

		for (key in buttonsPressed.keys())
			buttonsPressed.remove(key);

		buttonsJustPressed = false;
	}

	public function reset():Void
	{
		for (key in buttonsUp.keys())
			buttonsUp.remove(key);

		for (key in buttonsPressed.keys())
			buttonsPressed.remove(key);

		for (key in buttonsHeld.keys())
			buttonsHeld.remove(key);
	}

	function onGamepadAxis(axis:Int, value:Float):Void 
	{
		if(value < 0.1 && value > -0.1)
			value = 0;

		if (axis == 0)
			leftAnalog.x = value;
		else if (axis == 1)
			leftAnalog.y = value;
		else if (axis == 2)
			rightAnalog.x = value;
		else if (axis == 3)
			rightAnalog.y = value;
		else if (axis == 2)
			leftTrigger = value;
		else if (axis == 5)
			rightTrigger = value;
		else if (axis == 6) //Dpad comes in as an axis vs a button even though it only is -1, 0, or 1
		{
			if (value > 0)			
				onGamepadButton(GamePad.DRIGHT, 1);
			else if (value < 0)			
				onGamepadButton(GamePad.DLEFT, 1);			
			else
			{
				onGamepadButton(GamePad.DLEFT, 0);
				onGamepadButton(GamePad.DRIGHT, 0);
			}
		}
		else if (axis == 7)
		{
			if (value > 0)			
				onGamepadButton(GamePad.DUP, 1);
			else if (value < 0)			
				onGamepadButton(GamePad.DDOWN, 1);			
			else
			{
				onGamepadButton(GamePad.DUP, 0);
				onGamepadButton(GamePad.DDOWN, 0);
			}
		}			
		
		//Debug
		/*
		if (axis == 0){
			trace(value);
			if (value > 0.5){
				trace(value+' RIGHT LEFT ANALOG');
			} else if (value < -0.5){
				trace(value+' LEFT LEFT ANALOG');
			}
		}
		
		if (axis == 1){
			if (value > 0.5){
				trace(value+' UP LEFT ANALOG');
			} else if (value < -0.5){
				trace(value+' DOWN LEFT ANALOG');
			}
		}
		
		if (axis == 3){
			if (value > 0.5){
				trace(value+' LEFT RIGHT ANALOG');
			} else if (value < -0.5){
				trace(value+' RIGHT RIGHT ANALOG');
			}
		}
		
		if (axis == 4){
			if (value < -0.5){
				trace(value+' UP RIGHT ANALOG');
			} else if (value > 0.5){
				trace(value+' DOWN RIGHT ANALOG');
			}
		}
		
		if (axis == 2){
			if (value < -0.25){
				trace(value+' LEFT TRIGGER');
			}
		}
		
		if (axis == 5){
			if (value < -0.25){
				trace(value+' RIGHT TRIGGER');
			}
		}
		if(value > .2 || value <-.2)
		{
			trace("a"+axis);
			trace("v"+value);
		}
		*/
	}
	
	function onGamepadButton(button:Int, value:Float):Void 
	{
		if (value > 0)
		{
			buttonsJustPressed = true;
			buttonsPressed.set(button, true);
			buttonsHeld.set(button, true);
		}
		else
		{
			buttonsHeld.set(button, false);
			buttonsUp.set(button, true);
		}

		/*
		//Debug
		trace(button);
		if (button == 0){
			trace('A');
		} else if (button == 1){
			trace('B');
		} else if (button == 2){
			trace('X');
		} else if (button == 3){
			trace('Y');
		}
		
		if (button == 4){
			trace('LEFT BUMPER');
		}
		if (button == 5){
			trace('RIGHT BUMPER');
		}
		
		if (button == 6){
			trace('LEFT ANALOG PRESS');
		}
		if (button == 7){
			trace('RIGHT ANALOG PRESS');
		}
		
		if (button == 8){
			trace('START');
		}
		if (button == 9){
			trace('BACK');
		}
		if (button == 10){
			trace('HOME');
		}
		
		if (button == 11){
			trace('DPAD UP');
		} else if (button == 12){
			trace('DPAD DOWN');
		} else if (button == 13){
			trace('DPAD LEFT');
		} else if (button == 14){
			trace('DPAD RIGHT');
		}
		*/
	}

	inline public function isPressed(button:Int):Bool
	{
		return buttonsPressed.exists(button);
	}

	inline public function isHeld(button:Int):Bool
	{
		return buttonsHeld.get(button);
	}

	inline public function isUp(button:Int):Bool
	{
		return buttonsUp.exists(button);
	}

	inline public function isAnyHeld():Bool
	{
		return (buttonsCount > 0);
	}

	inline public function isAnyPressed():Bool
	{
		return buttonsJustPressed;
	}
}
