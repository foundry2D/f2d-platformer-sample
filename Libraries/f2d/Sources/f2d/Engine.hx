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
		
		F2d.windowWidth = System.windowWidth();
        F2d.halfWinWidth = Std.int(F2d.windowWidth / 2);
		F2d.windowHeight = System.windowHeight();
        F2d.halfWinHeight = Std.int(F2d.windowHeight / 2);
        
		this.useBackbuffer = useBackbuffer;

        if (useBackbuffer)
		{
			backbuffer = Image.createRenderTarget(width, height);

			F2d.gameWidth = backbuffer.width;
        	F2d.halfGameWidth = Std.int(backbuffer.width / 2);
			F2d.gameHeight = backbuffer.height;
        	F2d.halfGameHeight = Std.int(backbuffer.height / 2);

			render = renderWithBackbuffer;
		}
		else
		{
			F2d.gameWidth = F2d.windowWidth;
        	F2d.halfGameWidth = F2d.halfWinWidth;
			F2d.gameHeight = F2d.windowHeight;
        	F2d.halfGameHeight = F2d.halfWinHeight;

			render = renderWithFramebuffer;
		}

		if (fps != null)
			F2d.fixedDt = 1 / fps;
		else
			F2d.fixedDt = 1 / 60;
        
        calcGameScale();           
		
		managers = new Array<Manager>();
		F2d.screens = new Map<String, Screen>();		
	}
    
    inline function calcGameScale():Void
    {        
        F2d.gameScale = F2d.windowWidth / F2d.gameWidth;
    }
	
	function onForeground()
	{
		active = true;
		
		if (F2d.timeTasks != null)
		{
			for (id in F2d.timeTasks)
				Scheduler.pauseTimeTask(id, false);
		}
	}	
	
	function onBackground()
	{
		active = false;
		
		if (F2d.timeTasks != null)
		{
			for (id in F2d.timeTasks)
				Scheduler.pauseTimeTask(id, true);
		}
	}
	
	public function update():Void
	{
		// Make sure prev/curr time is updated to prevent time skips
		prevTime = currTime;
		currTime = Scheduler.time();
		
		F2d.dt = currTime - prevTime;
		
		if (active)
		{
			if (F2d.screen != null && F2d.screen.active)
			{
				F2d.screen.updateLists();
				
				F2d.screen.update();
				F2d.screen.updateLists(false);
				F2d.updateScreenShake();
			}
            
            #if debug
            if (F2d.editor != null)
            {
                F2d.editor.checkMode();
                
                if (F2d.editor.active)
                {
                    F2d.screen.updateLists();
                    F2d.editor.update();
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
		canvas.g2.begin(true, F2d.screen.bgColor);
		F2d.screen.render(canvas);					
            
		#if debug
        if (F2d.editor != null && F2d.editor.active)
            F2d.editor.render(canvas);
        #end

		if (persistentRender != null)
			persistentRender(canvas);

		if (!active && backgroundRender != null)
			backgroundRender(canvas);
        	
		canvas.g2.end();
	}

	function renderWithBackbuffer(framebuffer:Framebuffer):Void
	{
		if (F2d.screen != null)
		{
			renderGame(backbuffer);
			applyBackbufferToFramebuffer(framebuffer);			
		}
	}

	function renderWithBackbufferAndFilter(framebuffer:Framebuffer):Void
	{
		if (F2d.screen != null)
		{
			renderGame(Filter.texture);
			F2d.screen.filter.apply(backbuffer);
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
		if (F2d.screen != null)
			renderGame(framebuffer);
	}

	function renderWithFramebufferAndFilter(framebuffer:Framebuffer):Void
	{
		if (F2d.screen != null)
		{
			renderGame(Filter.texture);
			F2d.screen.filter.apply(framebuffer);
		}
	}	

	public function updateGameSize(newWidth:Int, newHeight:Int):Void
	{
		F2d.windowWidth = System.windowWidth();
        F2d.halfWinWidth = Std.int(F2d.windowWidth / 2);
		F2d.windowHeight = System.windowHeight();
        F2d.halfWinHeight = Std.int(F2d.windowHeight / 2);

		if (useBackbuffer)
		{
			backbuffer = Image.createRenderTarget(newWidth, newHeight);

			F2d.gameWidth = backbuffer.width;
        	F2d.halfGameWidth = Std.int(backbuffer.width / 2);
			F2d.gameHeight = backbuffer.height;
        	F2d.halfGameHeight = Std.int(backbuffer.height / 2);
		}
		else
		{
			F2d.gameWidth = F2d.windowWidth;
        	F2d.halfGameWidth = F2d.halfWinWidth;
			F2d.gameHeight = F2d.windowHeight;
        	F2d.halfGameHeight = F2d.halfWinHeight;
		}

		calcGameScale();

		if (F2d.screen != null)
			F2d.screen.gameSizeUpdated(newWidth, newHeight);
	}

	public function enablePauseOnLostFocus(value:Bool):Void
	{
		if (value)
			System.notifyOnApplicationState(onForeground, null, null, onBackground, null);
		else
			System.notifyOnApplicationState(null, null, null, null, null);
	}

	@:allow(f2d.F2d)
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
