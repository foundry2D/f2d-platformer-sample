package f2d.event;
import haxe.Constraints.Function;

interface IEventDispatcher
{
	public function dispatchEvent(name:String, eventObject:EventObject = null):Void;
	
	public function removeEvent(name:String, callback:Function):Void;

	public function addEvent(name:String, callback:Function):Void;
}
