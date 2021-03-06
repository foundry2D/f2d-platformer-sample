package f2d.components;

import f2d.event.EventObject;
import f2d.event.EventSystem;
import f2d.event.IEventDispatcher;
import haxe.Constraints.Function;

class EventDispatcher extends Component implements IEventDispatcher
{
	public function new()
	{
		super();
	}
	
	public override function init():Void 
	{
		super.init();
		object.eventDispatcher = this;
	}

	/**
	 * map of Function arrays, and the Event Constant Strings used to trigger them
	 */
	private var listeners:Map<String, Array<Function>> = new Map();
	
	/**
	 * Adds Event Listener for the name string and addes the callback to the functions to be 
	 * run when that event is fired off
	 * @param	name 		Event String that maps to array of callbacks
	 * @param	callback	callback to be added to array of callbacks upon event dispatch
	 */
	public function addEvent(name:String, callback:Function)
	{
		if (!listeners.exists(name))
		{
			listeners.set(name, [callback]);
			EventSystem.get().addEvent(name,this);
		}
		else if (listeners[name].indexOf(callback) == -1)
		{
			listeners[name].push(callback);
			EventSystem.get().addEvent(name,this);
		}
	}
	
	/**
	 * Removes Event Listener for the strings/callback combination
	 * 
	 * @param	name 		Event String that maps to array of callbacks
	 * @param	callback	callback to be removed from event
	 */
	public function removeEvent(name:String, callback:Function)
	{
		var i:Int;
		if (listeners.exists(name) && listeners[name].indexOf(callback) != -1)
		{
			for (i in 0...listeners[name].length)
			{
				if (listeners[name][i] == callback)
				{
					listeners[name].splice(i, 1);
					EventSystem.get().removeEvent(name,this);
					break;
				}
			}
		}
	}
	
	/**
	 * Triggers event using the name string. 
	 * The eventObject is passed to all callback functions listening to the event
	 * @param	name		Event to Trigger
	 * @param	eventObject	data the Event's callback functions need, creates a blank EventObject if left null
	 */
	public function dispatchEvent(name:String, eventObject:EventObject = null)
	{
		if (eventObject == null)
		{
			eventObject = new EventObject();
		}
		if (listeners.exists(name) && !eventObject.bubble)
		{
			for (func in listeners[name])
			{
				func(eventObject);
			}
		}
		if(eventObject.bubble)
		{
			EventSystem.get().dispatch(name, eventObject);
		}
	}

	public override function destroy():Void	
	{
		for(i in listeners.keys())
		{
			EventSystem.get().removeEvent(i, this);
			listeners.remove(i);
		}
	}
}
