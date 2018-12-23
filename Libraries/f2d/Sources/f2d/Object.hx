package f2d;

import kha.Color;
import kha.Canvas;
import kha.FastFloat;
import kha.math.Vector2;
import f2d.components.Component;
import f2d.math.Vector2b;
import f2d.event.IEventDispatcher;

@:allow(f2d.Screen)
class Object
{	
	/**
	 * A id to be used by the developer. 
	 * It's not used by the engine.
	 */
	public var id:Int;
	/** 
	 * A name for identification and debugging
	 */
	public var name:String;
	/**
	 * The x position 
	 */
	public var x:Float;
	/** 
	 * the y position 
	 */
	public var y:Float;
	/**
	 * The object width. This doesn't influence collision but some parts in the class uses it. 
	 * Call setSizeAuto() to set the width/height from the graphic.
	 */
	public var width:Int;
	/**
	 * The object height. This doesn't influence collision but some parts in the class uses it.
	 * Call setSizeAuto() to set the width/height from the graphic.
	 */
	public var height:Int;
	/**
	 * The x position in the right side (x + width)
	 */
	public var right(get, null):Float;
	/**
	 * The y position in the bottom side (y + height)
	 */
	public var bottom(get, null):Float;		
    /**
	 * If the Object should respond to collision checks.
	 */
	public var collidable:Bool;	
	/**
	 * If the object can update 
	 */ 
	public var active:Bool;		
	/**
	 * If the object should render
	 */
	public var visible(get, set):Bool;	
	/**
	 * The screen this object belongs 
	 */
	public var screen(default, null):Screen;
	/**
	 * The rendering layer of this Object. Higher layers are rendered first.
	 */
	public var layer(default, set):Int;		
    /**
	 * If the object should be fixed on screen. The camera position will be
	 * ignored on the rendering
	 */
    public var fixed:Vector2b;
	/**
	 * Components that updates and affect the object
	 */
	public var components:Array<Component>;
	/**
	 * Components that updates and affect the object
	 */
	public var eventDispatcher:IEventDispatcher;
	/**
	 * The graphic used by this object
	 */
	public var graphic(default, set):Graphic;        
	
	public function new(x:Float = 0, y:Float = 0, ?graphic:Graphic):Void
	{
		this.id = 0;
		this.name = '';	
		this.x = x;
		this.y = y;

		if (graphic != null)
			this.graphic = graphic;
        
        width = height = 0;
        
        collidable = true;		
		active = true;
		layer = 0;		
        fixed = new Vector2b();
		
		components = new Array<Component>();
	}
	
	/**
	 * Override this, called when the Object is added to a Screen.
	 */
	public function added():Void {}

	/**
	 * Override this, called when the Object is removed from a Screen.
	 */
	public function removed():Void {}
	
	public function destroy()
	{
		if (graphic != null)
			graphic.destroy();
		
		for (comp in components)		
			comp.destroy();		
	}
	
	public function update()
	{
		if (!active)
			return;
			
		if (graphic != null)
			graphic.update();
			
		for (comp in components)
		{
			if (comp.active)
				comp.update();
		}
	}
	
	public function setPosition(x:Float, y:Float):Void
	{
		this.x = x;
		this.y = y;
	}
	    
    /**
	 * Sets the Object's size	 	 
	 */
	public inline function setSize(width:Int, height:Int)
	{
		this.width = width;
		this.height = height;		
	}
    
	/**
	 * The position of the object relative to the screen.
	 * If the object wasn't added to a screen, the world position is returned.	 
	 */
	public function getScreenPosition():Vector2
	{
		if (screen != null)
			return new Vector2(x - screen.camera.x, y - screen.camera.y);
		else
			return new Vector2(x, y);
	}
	
	/**
	 * Add a component and initialize it
	 */
	public function addComponent(comp:Component)
	{
		components.push(comp);
		comp.object = this;
	}
	
	/**
	 * Removes a component
	 */
	inline public function removeComponent(comp:Component)
	{
		components.remove(comp);
	}
	
	function initComponents()
	{
		for (comp in components)
			comp.init();
	}
	
	public function render(canvas:Canvas, cameraX:Float, cameraY:Float):Void 
	{		
		graphic.render(canvas, x, y, cameraX, cameraY);		
	}
	
	/**
	 * Sets the size using the size of the graphic
	 */
	public function setSizeAuto():Void
    {                		
		if (graphic != null)
		{
			var size = graphic.getSize();
			width = size.x;
			height = size.y;
		}
		else
		{
			width = 0;
			height = 0;
			trace('(setSizeAuto) there isn\'t a graphic to get the size');			
		}
    }
	
	/**
	 * Tells if the object is inside the camera area
	 */
	public function onCamera():Bool
    {
        if (screen != null)
        {
            if (x > screen.camera.x && (x + width) < (screen.camera.x + screen.camera.width)
                && y > screen.camera.y && (y + height) < (screen.camera.y + screen.camera.height))
                    return true;
        }
        
        return false;
    }

	/**
	 * Checks if a point is inside the object
	 */
	public function pointInside(px:Float, py:Float):Bool
    {
        if (px > x && px < (x + width) && py > y && py < (y + height))
            return true;
        else
            return false;
    }
	
	private function set_layer(value:Int):Int
	{
		if (layer == value) return layer;
		if (screen == null)
		{
			layer = value;
			return layer;
		}
		screen.removeRender(this);
		layer = value;
		screen.addRender(this);
		
		return layer;
	}	
	
	private function set_graphic(value:Graphic):Graphic
	{
		if (value != null)
		{
			value.object = this;
			value.added();
		}
		
		return graphic = value;
	}
    
    /**
	 * Calculates the distance from another Object.
	 * @param	e				The other Object.	 
	 * @return	The distance.
	 */
	public inline function distanceFrom(e:Object):Float
	{
		return F2d.distanceRects(x, y, width, height, e.x, e.y, e.width, e.height);		
	}

	/**
	 * Calculates the distance from this Object to the point.
	 * @param	px				X position.
	 * @param	py				Y position.	 
	 * @return	The distance.
	 */
	public inline function distanceToPoint(px:Float, py:Float):Float
	{
		return F2d.distanceRectPoint(px, py, x, y, width, height);
	}

	/**
	 * Calculates the distance from this Object to the rectangle.
	 * @param	rx			X position of the rectangle.
	 * @param	ry			Y position of the rectangle.
	 * @param	rwidth		Width of the rectangle.
	 * @param	rheight		Height of the rectangle.
	 * @return	The distance.
	 */
	public inline function distanceToRect(rx:Float, ry:Float, rwidth:Float, rheight:Float):Float
	{
		return F2d.distanceRects(x, y, width, height, rx, ry, rwidth, rheight);
	}

	inline public function get_right():Float
	{
		return x + width;
	}

	inline public function get_bottom():Float
	{
		return y + height;
	}

	inline public function get_visible():Bool
	{
		return graphic.visible;
	}

	inline public function set_visible(value:Bool):Bool
	{
		return graphic.visible = value;
	}
        
     /**
	 * When you collide with an Object on the x-axis with hitbox.moveTo() or hitbox.moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e	The Object you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideX(object:Object):Bool
	{
		return true;
	}

	/**
	 * When you collide with an Object on the y-axis with hitbox.moveTo() or hitbox.moveBy()
	 * the engine call this function. Override it to detect and change the
	 * behaviour of collisions.
	 *
	 * @param	e	The Object you collided with.
	 *
	 * @return	If there was a collision.
	 */
	public function moveCollideY(object:Object):Bool
	{
		return true;
	}
}
