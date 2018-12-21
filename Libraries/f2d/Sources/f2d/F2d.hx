package f2d;

import kha.Scheduler;
import kha.graphics4.BlendingFactor;
import kha.math.Vector2;
import f2d.math.Point;
import f2d.math.Rectangle;
import f2d.util.Camera;

@:allow(f2d.Engine)
class F2d
{
	public static var fixedDt(default, null):Float = 0;
	public static var dt(default, null):Float = 0;
    	
	public static var windowWidth(default, null):Int;
    public static var halfWinWidth(default, null):Int;
	public static var windowHeight(default, null):Int;
    public static var halfWinHeight(default, null):Int;
    
    public static var gameWidth(default, null):Int;
    public static var halfGameWidth(default, null):Int;
	public static var gameHeight(default, null):Int;
    public static var halfGameHeight(default, null):Int;
    
	public static var screen:Screen;
	static var screens:Map<String, Screen>;
	
	public static var gameScale:Float = 1;
    
    /** Convert a radian value into a degree value. */
	public static var DEG(get, never):Float;
	private static inline function get_DEG(): Float { return -180 / Math.PI; }
    
    /** Convert a degree value into a radian value. */
	public static var RAD(get, never):Float;
	private static inline function get_RAD(): Float { return Math.PI / -180; }	
	
	static var timeTasks:Array<Int>;
	
	private static var shakeTime:Float = 0;
	private static var shakeMagnitude:Int = 0;
	private static var shakeX:Int = 0;
	private static var shakeY:Int = 0;

	#if debug
	/**
	 * Custom game editor. Needs to be extended to be used	
	 */
    public static var editor:Editor;
    #end                      

	public static function addScreen(name:String, screen:Screen, goToScreen:Bool = false):Void
	{
		screens.set(name, screen);

		if (goToScreen)
			switchScreen(name);
	}

	public static function removeScreen(name:String, destroy:Bool = false):Void
	{
		if (destroy)
		{
			var screen = screens.get(name);
			screens.remove(name);

			if (screen != null)
				screen.destroy();
		}
		else
			screens.remove(name);
	}

	public static function switchScreen(name:String):Bool
	{
		var screenSwitched = screens.get(name);

		if (screenSwitched != null)
		{			
			screen = screenSwitched;
			Engine.instance.chooseRenderFunction(screen.filter);

			screen.init();

			return true;
		}
		
		return false;
	}	
	
	public static function addTimeTask(task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0):Int
	{
		if (timeTasks == null)
			timeTasks = new Array<Int>();
		
		timeTasks.push(Scheduler.addTimeTask(task, start, period, duration));
		
		return timeTasks[timeTasks.length - 1];
	}
	
	public static function removeTimeTask(id:Int):Void
	{
		if (timeTasks != null)
		{
			timeTasks.remove(id);
			Scheduler.removeTimeTask(id);
		}
	}
	
	/**
	 * Empties an array of its' contents
	 * @param array filled array
	 */
	public static inline function clear(array:Array<Dynamic>)
	{
		#if (cpp || php)
		array.splice(0, array.length);
		#else
		untyped array.length = 0;
		#end
	}
	
	/**
	 * Binary insertion sort
	 * @param list     A list to insert into
	 * @param key      The key to insert
	 * @param compare  A comparison function to determine sort order
	 */
	public static function insertSortedKey<T>(list:Array<T>, key:T, compare:T->T->Int):Void
	{
		var result:Int = 0,
			mid:Int = 0,
			min:Int = 0,
			max:Int = list.length - 1;
			
		while (max >= min)
		{
			mid = min + Std.int((max - min) / 2);
			result = compare(list[mid], key);
			if (result > 0) max = mid - 1;
			else if (result < 0) min = mid + 1;
			else return;
		}

		list.insert(result > 0 ? mid : mid + 1, key);
	}
    
    /**
	 * Find the distance between two points.
	 * @param	x1		The first x-position.
	 * @param	y1		The first y-position.
	 * @param	x2		The second x-position.
	 * @param	y2		The second y-position.
	 * @return	The distance.
	 */
	public static inline function distance(x1:Float, y1:Float, x2:Float = 0, y2:Float = 0):Float
	{
		return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
	}
    
    /**
	 * Find the distance between two rectangles. Will return 0 if the rectangles overlap.
	 * @param	x1		The x-position of the first rect.
	 * @param	y1		The y-position of the first rect.
	 * @param	w1		The width of the first rect.
	 * @param	h1		The height of the first rect.
	 * @param	x2		The x-position of the second rect.
	 * @param	y2		The y-position of the second rect.
	 * @param	w2		The width of the second rect.
	 * @param	h2		The height of the second rect.
	 * @return	The distance.
	 */
	public static function distanceRects(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Float
	{
		if (x1 < x2 + w2 && x2 < x1 + w1)
		{
			if (y1 < y2 + h2 && y2 < y1 + h1) return 0;
			if (y1 > y2) return y1 - (y2 + h2);
			return y2 - (y1 + h1);
		}
		if (y1 < y2 + h2 && y2 < y1 + h1)
		{
			if (x1 > x2) return x1 - (x2 + w2);
			return x2 - (x1 + w1);
		}
		if (x1 > x2)
		{
			if (y1 > y2) return distance(x1, y1, (x2 + w2), (y2 + h2));
			return distance(x1, y1 + h1, x2 + w2, y2);
		}
		if (y1 > y2) return distance(x1 + w1, y1, x2, y2 + h2);
		return distance(x1 + w1, y1 + h1, x2, y2);
	}
    
    /**
	 * Find the distance between a point and a rectangle. Returns 0 if the point is within the rectangle.
	 * @param	px		The x-position of the point.
	 * @param	py		The y-position of the point.
	 * @param	rx		The x-position of the rect.
	 * @param	ry		The y-position of the rect.
	 * @param	rw		The width of the rect.
	 * @param	rh		The height of the rect.
	 * @return	The distance.
	 */
	public static function distanceRectPoint(px:Float, py:Float, rx:Float, ry:Float, rw:Float, rh:Float):Float
	{
		if (px >= rx && px <= rx + rw)
		{
			if (py >= ry && py <= ry + rh) return 0;
			if (py > ry) return py - (ry + rh);
			return ry - py;
		}
		if (py >= ry && py <= ry + rh)
		{
			if (px > rx) return px - (rx + rw);
			return rx - px;
		}
		if (px > rx)
		{
			if (py > ry) return distance(px, py, rx + rw, ry + rh);
			return distance(px, py, rx + rw, ry);
		}
		if (py > ry) return distance(px, py, rx, ry + rh);
		return distance(px, py, rx, ry);
	}
    
    /**
	 * Clamps the value within the minimum and maximum values.
	 * @param	value		The Float to evaluate.
	 * @param	min			The minimum range.
	 * @param	max			The maximum range.
	 * @return	The clamped value.
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}
    
    /**
	 * Linear interpolation between two values.
	 * @param	a		First value.
	 * @param	b		Second value.
	 * @param	t		Interpolation factor.
	 * @return	When t=0, returns a. When t=1, returns b. When t=0.5, will return halfway between a and b. Etc.
	 */
	public static inline function lerp(a:Float, b:Float, t:Float = 1):Float
	{
		return a + (b - a) * t;
	}

	/**
	 * Linear interpolation between two colors.
	 * @param	fromColor		First color.
	 * @param	toColor			Second color.
	 * @param	t				Interpolation value. Clamped to the range [0, 1].
	 * return	RGB component-interpolated color value.
	 */
	public static inline function colorLerp(fromColor:Int, toColor:Int, t:Float = 1):Int
	{
		if (t <= 0)
		{
			return fromColor;
		}
		else if (t >= 1)
		{
			return toColor;
		}
		else
		{
			var a:Int = fromColor >> 24 & 0xFF,
				r:Int = fromColor >> 16 & 0xFF,
				g:Int = fromColor >> 8 & 0xFF,
				b:Int = fromColor & 0xFF,
				dA:Int = (toColor >> 24 & 0xFF) - a,
				dR:Int = (toColor >> 16 & 0xFF) - r,
				dG:Int = (toColor >> 8 & 0xFF) - g,
				dB:Int = (toColor & 0xFF) - b;
			a += Std.int(dA * t);
			r += Std.int(dR * t);
			g += Std.int(dG * t);
			b += Std.int(dB * t);
			return a << 24 | r << 16 | g << 8 | b;
		}
	}

	/**
	 * Transfers a value from one scale to another scale. For example, scale(.5, 0, 1, 10, 20) == 15, and scale(3, 0, 5, 100, 0) == 40.
	 * @param	value		The value on the first scale.
	 * @param	min			The minimum range of the first scale.
	 * @param	max			The maximum range of the first scale.
	 * @param	min2		The minimum range of the second scale.
	 * @param	max2		The maximum range of the second scale.
	 * @return	The scaled value.
	 */
	public inline static function scale(value:Float, min:Float, max:Float, min2:Float, max2:Float):Float
	{
		return min2 + ((value - min) / (max - min)) * (max2 - min2);
	}
	
	/**
	 * Normalizes a value between 0 and 1;
	 * @param	min Minimum value
	 * @param	max Maximum value
	 * @param	value The value that needs to be normalized
	 * @return
	 */
	public static function normalize(min:Float, max:Float, value:Float) : Float
	{
		var n:Float = (value - min) / (max - min);
		n = n > 1 ? 1:n;
		n = n < 0 ? 0:n;
		return n;
	}

	public static function shake(magnitude:Int, duration:Float)
	{
		if (shakeTime < duration) shakeTime = duration;
		shakeMagnitude = magnitude;
	}

	/**
	 * Stop the screen from shaking immediately.
	 */
	public static function shakeStop()
	{
		shakeTime = 0;
	}
		
	private inline static function updateScreenShake():Void
	{
		if (shakeTime > 0)
		{
			var sx:Int = Std.random(shakeMagnitude * 2 + 1) - shakeMagnitude;
			var sy:Int = Std.random(shakeMagnitude * 2 + 1) - shakeMagnitude;

			screen.camera.x += sx - shakeX;
			screen.camera.y += sy - shakeY;

			shakeX = sx;
			shakeY = sy;

			shakeTime -= dt;
			if (shakeTime < 0) shakeTime = 0;
		}
		else if (shakeX != 0 || shakeY != 0)
		{
			screen.camera.x -= shakeX;
			screen.camera.y -= shakeY;
			shakeX = shakeY = 0;
		}
	}
	
	#if sys_g4
	public static function getBlendingFactor(code:Int):BlendingFactor
	{
		switch(code)
		{
			case 0: 		return BlendingFactor.BlendZero;
			case 1:			return BlendingFactor.BlendOne;
			case 0x0300:	return BlendingFactor.SourceColor;
			case 0x0301:	return BlendingFactor.InverseSourceColor;
			case 0x0302:	return BlendingFactor.SourceAlpha;
			case 0x0303:	return BlendingFactor.InverseSourceAlpha;
			case 0x0304:	return BlendingFactor.DestinationAlpha;
			case 0x0305:	return BlendingFactor.InverseDestinationAlpha;
			case 0x0306:	return BlendingFactor.DestinationColor;
			case 0x0307:	return BlendingFactor.InverseDestinationColor;
			default:
				trace('(getBlendingMode) BlendingFactor not found');
				return null;
		}
	}
	#end
}
