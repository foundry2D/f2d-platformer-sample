package f2d.components;

import kha.Image;
import f2d.graphics.Sprite;
import f2d.atlas.Region;

// TODO: Optimize for animations of one frame

class AnimData 
{
	public var name:String;	
	public var regions:Array<Region>;
	public var fps:Int;
	
	public function new(name:String, regions:Array<Region>, fps:Int):Void
	{
		this.name = name;
		this.regions = regions;
		this.fps = fps;
	}
}

class Animator extends Component
{	
	var sprite:Sprite;
	/**
	 * positive = forward, negative = backwards 
	 */
	var direction:Float; 
	
	var animations:Map<String, AnimData>;	
	
	var currAnimation:AnimData;
	
	var currIndex:Int;
		
	var loop:Bool;
	
	var elapsed:Float;	
	/** 
	 * The name of the current animation 
	 */
	public var nameAnim(default, null):String;
	
	public function new():Void
	{
		super();
		
		active = false;
		direction = 1;
		currIndex = 0;
		loop = false;
		elapsed = 0;
		nameAnim = '';
		
		animations = new Map<String, AnimData>();
	}
	
	override public function init():Void 
	{
		if (Std.is(object.graphic, Sprite))
			sprite = cast object.graphic;
		else
		{
			trace('Animator failed. The object "${object.name}" doesn\'t have a sprite');
			sprite = null;
		}
	}
	
	override public function update():Void
	{
		elapsed += Sdg.dt * Math.abs(direction);

		// next frame
		if (elapsed >= 1 / currAnimation.fps)
		{
			elapsed -= (1 / currAnimation.fps);

			currIndex += (direction >= 0) ? 1 : -1;

			if (currIndex >= currAnimation.regions.length)
			{
				if (!loop)
				{
					stop();
					return;
				}
				
				currIndex = 0;
			}					
			else if (currIndex < 0)
			{
				if (!loop)
				{
					stop();
					return;
				}						
					
				currIndex = currAnimation.regions.length - 1;
			}					
		}

		// update region
		sprite.region = currAnimation.regions[currIndex];		
	}
	
	override public function destroy():Void
	{		
		currAnimation = null;
		animations = null;
		
		super.destroy();
	}
	
	public function addAnimation(name:String, regions:Array<Region>, fps:Int = 12):Void
	{
		if (animations.exists(name))
			trace('animation $name already exists, overwriting...');

		animations.set(name, new AnimData(name, regions, fps));		
	}
	
	public function removeAnimation(name:String):Void
	{
		animations.remove(name);
	}
	
	/**
	* Play a animation. Don't call this all the time,
	* Check first if the animation that will be played
	* is already running. To do this, compare the name
	* of the animation with nameAnim
	*/	
	public function play(name:String, loop:Bool=true)
	{		
		var animData:AnimData = animations.get(name);

		if (animData != null)
		{			
			currAnimation = animData;
			nameAnim = animData.name;
			this.loop = loop;
			restart();
		}
		else
		{
			trace('animation $name does not exist');
			return;
		}	
	}
	
	inline public function pause()
	{
		active = false;
	}
	
	inline public function resume()
	{
		active = true;
	}

	public function stop()
	{
		active = false;
		currIndex = 0;
		elapsed = 0;
	}
	
	public function restart()
	{
		active = true;
		currIndex = 0;
		elapsed = 0;
	}
	
	/**
	* Reverses the animation 
	*/
	public function reverse(value:Bool):Void
	{
		if (value)
			direction = 1;
		else
			direction = -1;
	}
}
