package f2d.event;
import haxe.ds.StringMap;

class EventSystem
{
	private static var instance:EventSystem;

	private var dispatchers:Array<IEventDispatcher> = [];

	private var dispatchMap:StringMap<Array<IEventDispatcher>> = new StringMap<Array<IEventDispatcher>>();

	private function new()
	{

	}

	public static function get()
	{
		if(instance == null)
			instance = new EventSystem();
		return instance;
	}

	public function addEvent(name:String, eventDispatcher:IEventDispatcher)
	{
		if(!dispatchMap.exists(name))
			dispatchMap.set(name,[eventDispatcher]);
		else
			dispatchMap.get(name).push(eventDispatcher);
	}

	public function removeEvent(name:String, eventDispatcher:IEventDispatcher)
	{
		if(dispatchMap.exists(name))
		{
			dispatchMap.get(name).remove(eventDispatcher);
		}
	}

	public function dispatch(name:String, eventObject:EventObject)
	{
  		if(dispatchMap.exists(name))
		{
			for(i in dispatchMap.get(name))
			{
				eventObject.bubble = false;
				i.dispatchEvent(name, eventObject);
			}
		}
	}
}
