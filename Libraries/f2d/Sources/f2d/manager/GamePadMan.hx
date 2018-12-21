package f2d.manager;

@:allow(f2d.manager.GamePad)
class GamePadMan extends Manager
{
	static var gamePads:Map<Int, GamePad>;	

	function new()
	{
		super();
		
		gamePads = new Map<Int, GamePad>();

		for (i in 0...4)
		{
			if (kha.input.Gamepad.get(i) != null)
			{
				var gamePad = new GamePad(i);
				var khaGamePad = kha.input.Gamepad.get(i);

				if (khaGamePad != null)
				{
					khaGamePad.notify(gamePad.onGamepadAxis, gamePad.onGamepadButton);
					gamePads.set(i, gamePad);
					gamePad.active = true;
				}
				else
					gamePad.active = false;
			}
		}
	}	

	override public function update():Void
	{
		super.update();

		for (i in gamePads.keys())		
			gamePads[i].update();		
	}

	override public function reset():Void
	{
		super.reset();
		
		for(i in gamePads.keys())		
			gamePads[i].reset();		
	}
}
