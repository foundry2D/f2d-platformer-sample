#if debug
package f2d;

import kha.Canvas;
import kha.input.KeyCode;
import f2d.manager.Keyboard;

class Editor
{
    public var active:Bool;
    var activationKey:KeyCode;
    
    public function new(activationKey:KeyCode):Void
    {
        active = false;
        this.activationKey = activationKey;
    }
    
    public function checkMode():Void
    {
        if (Keyboard.isPressed(activationKey))
        {
            if (!active)
            {
                F2d.screen.active = false;
                active = true;
                open();
            }
            else
            {
                F2d.screen.active = true;
                active = false;
                close();
            }
        }
    }
    
    public function open():Void {}

    public function close():Void {}
    
    public function update():Void {}
    
    public function render(canvas:Canvas):Void {}    
}
#end
