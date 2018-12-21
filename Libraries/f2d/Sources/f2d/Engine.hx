package f2d;

import kha.Color;
import kha.Image;
import kha.System;
import kha.Scaler;
import kha.Canvas;
import kha.Scheduler;
import kha.Framebuffer;
import kha.graphics2.ImageScaleQuality;
import f2d.manager.Manager;
import f2d.filters.Filter;

class Engine
{
	public static var instance:Engine;

	public var backbuffer:Image;
	
	var currTime:Float = 0;
	var prevTime:Float = 0;
	var active:Bool;
	
	var managers:Array<Manager>;
	
	public var backgroundRender:Canvas->Void;
	public var persistentRender:Canvas->Void;

	public var render:Framebuffer->Void;

	public var highQualityScale:Bool;
	public var useBackbuffer(default, null):Bool;
	
	public function new(width:Int, height:Int, highQualityScale:Bool = false, useBackbuffer:Bool = true, ?fps:Null<Int>):Void
	{
		instance = this;

		active = true;
		this.highQualityScale = highQualityScale;		
		
		currTime = Scheduler.time();
		
		Sdg.windowWidth = System.windowWidth();
        Sdg.halfWinWidth = Std.int(Sdg.windowWidth / 2);
		Sdg.windowHeight = System.windowHeight();
        Sdg.halfWinHeight = Std.int(Sdg.windowHeight / 2);
        
		this.useBackbuffer = useBackbuffer;

        if (useBackbuffer)
		{
			backbuffer = Image.createRenderTarget(width, height);

			Sdg.gameWidth = backbuffer.width;
        	Sdg.halfGameWidth = Std.int(backbuffer.width / 2);
			Sdg.gameHeight = backbuffer.height;
        	Sdg.halfGameHeight = Std.int(backbuffer.height / 2);

			render = renderWithBackbuffer;
		}
		else
		{
			Sdg.gameWidth = Sdg.windowWidth;
        	Sdg.halfGameWidth = Sdg.halfWinWidth;
			Sdg.gameHeight = Sdg.windowHeight;
        	Sdg.halfGameHeight = Sdg.halfWinHeight;

			render = renderWithFramebuffer;
		}

		if (fps != null)
			Sdg.fixedDt = 1 / fps;
		else
			Sdg.fixedDt = 1 / 60;
        
        calcGameScale();           
		
		managers = new Array<Manager>();
		Sdg.screens = new Map<String, Screen>();		
	}
    
    inline function calcGameScale():Void
    {        
        Sdg.gameScale = Sdg.windowWidth / Sdg.gameWidth;
    }
	
	function onForeground()
	{
		active = true;
		
		if (Sdg.timeTasks != null)
		{
			for (id in Sdg.timeTasks)
				Scheduler.pauseTimeTask(id, false);
		}
	}	
	
	function onBackground()
	{
		active = false;
		
		if (Sdg.timeTasks != null)
		{
			for (id in Sdg.timeTasks)
				Scheduler.pauseTimeTask(id, true);
		}
	}
	
	public function update():Void
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();
		
		Sdg.dt = currTime - prevTime;
		
		if (active)
		{
			if (Sdg.screen != null && Sdg.screen.active)
			{
				Sdg.screen.updateLists();
				
				Sdg.screen.update();
				Sdg.screen.updateLists(false);
				Sdg.updateScreenShake();
			}
            
            #if debug
            if (Sdg.editor != null)
            {
                Sdg.editor.checkMode();
                
                if (Sdg.editor.active)
                {
                    Sdg.screen.updateLists();
                    Sdg.editor.update();
                }
                    
            }
            #end
            			
			// Events will always trigger first, and we want the active screen
			// to react to the changes before the manager processes them.
			for (m in managers)
			{
				if (m.active)
					m.update();
			}
		}		
	}	

	/**
	 * Enable managers to be updated by the engine
	 */
	public function enable(options:Int):Void
	{
		if (options & Manager.KEYBOARD == Manager.KEYBOARD)
			managers.push(new f2d.manager.Keyboard());

		if (options & Manager.MOUSE == Manager.MOUSE)
			managers.push(new f2d.manager.Mouse());

		if (options & Manager.TOUCH == Manager.TOUCH)
			managers.push(new f2d.manager.Touch());	

		if (options & Manager.GAMEPAD == Manager.GAMEPAD)
			managers.push(f2d.manager.GamePad.getManager());
		
		#if Delta
		if (options & Manager.DELTA == Manager.DELTA)
			managers.push(new f2d.manager.TweenDelta());		
		#end
	}
	
	function renderGame(canvas:Canvas):Void
	{							
		canvas.g2.begin(true, Sdg.screen.bgColor);
		Sdg.screen.render(canvas);					
            
		#if debug
        if (Sdg.editor != null && Sdg.editor.active)
            Sdg.editor.render(canvas);
        #end

		if (persistentRender != null)
			persistentRender(canvas);

		if (!active && backgroundRender != null)
			backgroundRender(canvas);
        	
		canvas.g2.end();
	}

	function renderWithBackbuffer(framebuffer:Framebuffer):Void
	{
		if (Sdg.screen != null)
		{
			renderGame(backbuffer);
			applyBackbufferToFramebuffer(framebuffer);			
		}
	}

	function renderWithBackbufferAndFilter(framebuffer:Framebuffer):Void
	{
		if (Sdg.screen != null)
		{
			renderGame(Filter.texture);
			Sdg.screen.filter.apply(backbuffer);
			applyBackbufferToFramebuffer(framebuffer);
		}
	}

	inline function applyBackbufferToFramebuffer(framebuffer:Framebuffer):Void
	{
		framebuffer.g2.begin();

		if (highQualityScale)
			framebuffer.g2.imageScaleQuality = ImageScaleQuality.High;
			
		Scaler.scale(backbuffer, framebuffer, System.screenRotation);
		framebuffer.g2.end();
	}

	function renderWithFramebuffer(framebuffer:Framebuffer):Void
	{
		if (Sdg.screen != null)
			renderGame(framebuffer);
	}

	function renderWithFramebufferAndFilter(framebuffer:Framebuffer):Void
	{
		if (Sdg.screen != null)
		{
			renderGame(Filter.texture);
			Sdg.screen.filter.apply(framebuffer);
		}
	}	

	public function updateGameSize(newWidth:Int, newHeight:Int):Void
	{
		Sdg.windowWidth = System.windowWidth();
        Sdg.halfWinWidth = Std.int(Sdg.windowWidth / 2);
		Sdg.windowHeight = System.windowHeight();
        Sdg.halfWinHeight = Std.int(Sdg.windowHeight / 2);

		if (useBackbuffer)
		{
			backbuffer = Image.createRenderTarget(newWidth, newHeight);

			Sdg.gameWidth = backbuffer.width;
        	Sdg.halfGameWidth = Std.int(backbuffer.width / 2);
			Sdg.gameHeight = backbuffer.height;
        	Sdg.halfGameHeight = Std.int(backbuffer.height / 2);
		}
		else
		{
			Sdg.gameWidth = Sdg.windowWidth;
        	Sdg.halfGameWidth = Sdg.halfWinWidth;
			Sdg.gameHeight = Sdg.windowHeight;
        	Sdg.halfGameHeight = Sdg.halfWinHeight;
		}

		calcGameScale();

		if (Sdg.screen != null)
			Sdg.screen.gameSizeUpdated(newWidth, newHeight);
	}

	public function enablePauseOnLostFocus(value:Bool):Void
	{
		if (value)
			System.notifyOnApplicationState(onForeground, null, null, onBackground, null);
		else
			System.notifyOnApplicationState(null, null, null, null, null);
	}

	@:allow(f2d.Sdg)
	@:allow(f2d.Screen)
	@:allow(f2d.filters.Filter)
	function chooseRenderFunction(filter:Filter):Void
	{
		var isUsingFilter = (filter != null && filter.enabled);
		
		if (useBackbuffer)
		{
			if (isUsingFilter)
				render = renderWithBackbufferAndFilter;
			else
				render = renderWithBackbuffer;
		}
		else
		{
			if (isUsingFilter)
				render = renderWithFramebufferAndFilter;
			else
				render = renderWithFramebuffer;
		}
	}
}
