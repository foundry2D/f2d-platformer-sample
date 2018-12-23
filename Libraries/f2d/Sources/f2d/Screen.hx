package f2d;

import kha.Color;
import kha.Canvas;
import kha.math.Vector2;
import f2d.math.Rectangle;
import f2d.util.Camera;
import f2d.filters.Filter;

class Screen
{
    public var active:Bool;
    
	var layerList:Array<Int>;
	
	var addList:Array<Object>;
	var removeList:Array<Object>;
    var destroyList:Array<Object>;
	
	var updateList:List<Object>;
	var layerDisplay:Map<Int,Bool>;
	var layers:Map<Int,List<Object>>;
        
	var objectNames:Map<String, Object>;	
	
	/** 
	 * The background color 
	 */
	public var bgColor:Color;	
	
	public var camera:Camera;

	public var worldWidth:Int;
	public var worldHeight:Int;

	public var filter(default, set):Filter;
	
	public function new():Void
	{
        active = true;		
        
		layerList = new Array<Int>();
	
		addList = new Array<Object>();
		removeList = new Array<Object>();
        destroyList = new Array<Object>();
		
		updateList = new List<Object>();
		layerDisplay = new Map<Int,Bool>();
		layers = new Map<Int,List<Object>>();
		objectNames = new Map<String,Object>();
				
		bgColor = Color.Black;		
		
		camera = new Camera(this);
		worldWidth = F2d.gameWidth;
		worldHeight = F2d.gameHeight;
	}
    
    public function init():Void {}
    
    public function close():Void {}
	
	/**
	 * Performed by the game loop, updates all contained Entities.
	 * If you override this to give your Scene update code, remember
	 * to call super.update() or your Entities will not be updated.
	 */
	public function update():Void
	{		
		for (object in updateList)
		{
			if (object.active)
				object.update();
		}
	}
	
	/**
	 * Toggles the visibility of a layer
	 * @param layer the layer to show/hide
	 * @param show whether to show the layer (default: true)
	 */
	public inline function showLayer(layer:Int, show:Bool = true):Void
	{
		layerDisplay.set(layer, show);
	}
	
	/**
	 * Checks if a layer is visible or not
	 */
	public inline function layerVisible(layer:Int):Bool
	{
		return !layerDisplay.exists(layer) || layerDisplay.get(layer);
	}

	public inline function setWorldSize(width:Int, height:Int):Void
	{
		worldWidth = width;
		worldHeight = height;
	}	
	
	/**
	 * Performed by the game loop, renders all contained Entities.
	 * If you override this to give your Scene render code, remember
	 * to call super.render() or your Entities will not be rendered.
	 */
	public function render(canvas:Canvas):Void
	{				
		// render the entities in order of depth
		for (layer in layerList)
		{
			if (!layerVisible(layer)) 
				continue;
			
			for (object in layers.get(layer))
			{
				if (object.graphic != null && object.graphic.visible)
					object.render(canvas, !object.fixed.x ? camera.x : 0, !object.fixed.y ? camera.y : 0);				
			}
		}
	}
	
	public function destroy():Void
	{
		layerList = null;
		addList = null;
		layerDisplay = null;
		layers = null;		
		objectNames = null;
		
		for (object in updateList)
			object.destroy();
			
		removeList = null;
		updateList = null;
	}	
	
	/**
	 * Adds the object to the screen at the end of the frame.
	 * @param	object		Object you want to add.
	 * @return	The added object.
	 */
	public function add(object:Object):Object
	{
		addList[addList.length] = object;
		return object;
	}
	
	/**
	 * Removes the object from the screen at the end of the frame.
	 * @param	e		Object you want to remove.
	 * @return	The removed object.
	 */
	public function remove(object:Object, destroy:Bool = false):Object
	{
		removeList[removeList.length] = object;
        
        if (destroy)
            destroyList[destroyList.length] = object;
        
		return object;
	}

	/**
	 * Creates an object and add to the screen 
	 */
	public function create(x:Float, y:Float, graphic:Graphic, ?layer:Null<Int>):Object
	{
		var object = new Object(x, y);
		object.graphic = graphic;

		if (layer != null)
			object.layer = layer;

		add(object);

		return object;
	}
	
	/**
	 * Adds multiple objects to the screen.
	 * @param	list		Several objects (as arguments) or an Array/Vector of objects.
	 */
	public function addObjects<Obj:Object>(list:Iterable<Obj>)
	{
		for (object in list) 
			add(object);
	}
	
	/**
	 * Removes multiple objects to the screen.
	 * @param	list		Several objects (as arguments) or an Array/Vector of objects.
	 */
	public function removeObjects<Obj:Object>(list:Iterable<Obj>)
	{
		for (object in list) 
			remove(object);
	}
	
	/**
	 * Brings the object to the front of its contained layer.
	 * @param	object		The object to shift.
	 * @return	If the object changed position.
	 */
	public function bringToFront(object:Object):Bool
	{
		if (object.screen != this) 
			return false;
			
		var list = layers.get(object.layer);
		list.remove(object);
		list.push(object);
		return true;
	}
	
	/**
	 * Sends the object to the back of its contained layer.
	 * @param	object		The object to shift.
	 * @return	If the object changed position.
	 */
	public function sendToBack(object:Object):Bool
	{
		if (object.screen != this) 
			return false;
			
		var list = layers.get(object.layer);
		list.remove(object);
		list.add(object);
		return true;
	}
	
	/**
	 * If the object as at the front of its layer.
	 * @param	object		The object to check.
	 * @return	True or false.
	 */
	public inline function isAtFront(object:Object):Bool
	{
		return object == layers.get(object.layer).first();
	}

	/**
	 * If the object as at the back of its layer.
	 * @param	object		The object to check.
	 * @return	True or false.
	 */
	public inline function isAtBack(object:Object):Bool
	{
		return object == layers.get(object.layer).last();
	}	
	
	/**
	 * Returns the object with the instance name, or null if none exists
	 * @param	name
	 * @return	The object.
	 */
	public function getInstance(name:String):Object
	{
		return objectNames.get(name);
	}
	
	/**
	 * Updates the add/remove lists at the end of the frame.
	 * @param	shouldAdd	If new objects should be added to the screen.
	 */
	public function updateLists(shouldAdd:Bool = true):Void
	{
		var object:Object;

		// remove objects
		if (removeList.length > 0)
		{
			for (object in removeList)
			{
				if (object.screen == null)
				{
					var idx = addList.indexOf(object);
					if (idx >= 0)
						addList.splice(idx, 1);
					continue;
				}
				
				if (object.screen != this)
					continue;
					
				object.removed();
				
				object.screen = null;
				removeUpdate(object);
				removeRender(object);
				
				//if (object.type != "") removeType(object);
				if (object.name != "") unregisterName(object);
			}
			F2d.clear(removeList);
		}
        
        if (destroyList.length > 0)
        {
            for (object in destroyList)
			{
				object.destroy();
                object = null;
			}   
            F2d.clear(destroyList);
        }

		// add objects
		if (shouldAdd && addList.length > 0)
		{
			for (object in addList)
			{
				if (object.screen != null)
					continue;
					
				object.screen = this;
				addUpdate(object);
				addRender(object);
				
				//if (object.type != "")
				//	addType(object);
				if (object.name != "") 
					registerName(object);
					
				object.added();
				object.initComponents();
			}
			F2d.clear(addList);
		}		
	}
	
	/** 
	 * Adds object to the update list. 
	 */
	inline private function addUpdate(object:Object):Void
	{
		// add to update list
		updateList.add(object);		
	}

	/** 
	 * Removes object from the update list. 
	 */
	inline private function removeUpdate(object:Object):Void
	{
		updateList.remove(object);		
	}
	
	/** 
	 * Adds object to the render list. 
	 */
	@:allow(f2d.Object)
	private function addRender(object:Object):Void
	{
		var list:List<Object>;
		
		if (layers.exists(object.layer))		
			list = layers.get(object.layer);		
		else
		{
			// Create new layer with entity.
			list = new List<Object>();
			layers.set(object.layer, list);

			if (layerList.length == 0)			
				layerList[0] = object.layer;			
			else			
				F2d.insertSortedKey(layerList, object.layer, layerSort);			
		}
		
		list.add(object);
	}
	
	/** 
	 * Removes object from the render list. 
	 */
	@:allow(f2d.Object)
	private function removeRender(object:Object):Void
	{
		var list = layers.get(object.layer);
		list.remove(object);
		
		if (list.length == 0)
		{
			layerList.remove(object.layer);
			layers.remove(object.layer);
		}
	}

	/**
	 * Sorts layer from highest value to lowest
	 */
	private function layerSort(a:Int, b:Int):Int
	{
		return b - a;
	}		
	
	/** 
	 * Register the entities instance name. 
	 */
	@:allow(f2d.Object)
	inline private function registerName(object:Object):Void
	{
		objectNames.set(object.name, object);
	}

	/** 
	 * Unregister the entities instance name. 
	 */
	@:allow(f2d.Object)
	inline private function unregisterName(object:Object):Void
	{
		objectNames.remove(object.name);
	}

	/**
	 * Override this to be called when the screen size is updated
	 * by engine.updateGameSize()
	 */
	public function gameSizeUpdated(newWidth:Int, newHeight:Int):Void {}

	function set_filter(value:Filter):Filter
	{
		filter = value;
		Engine.instance.chooseRenderFunction(filter);

		return filter;		
	}
}
