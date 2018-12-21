package f2d.graphics.text;

import kha.Font;
import kha.Color;
import kha.Canvas;
import f2d.graphics.text.Text.TextOptions;
import f2d.graphics.text.Text.TextAlign;

class TextShadow extends Text
{
	public var shadowX:Float;
	
	public var shadowY:Float;	
	
	public var shadowColor:Color;
	
	public var shadowAlpha:Float;
	
	public function new(text:String, font:Font, fontSize:Int, boxWidth:Int = 0, ?option:TextOptions):Void
	{
		super(text, font, fontSize, boxWidth, option);

		shadowX = 2;
		shadowY = 2;		
		shadowColor = Color.Black;
		shadowAlpha = 0.3;
	}	

	override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
		cursor.x = 0;
		cursor.y = shadowY;

		canvas.g2.font = font;
		canvas.g2.fontSize = fontSize;

		canvas.g2.color = shadowColor;

		if (shadowAlpha != 1)
			canvas.g2.pushOpacity(shadowAlpha);		

		for (line in lines)
		{			
			if (boxWidth > 0)
			{
				switch (align)
				{
					case TextAlign.Left: cursor.x = shadowX;
					case TextAlign.Right: cursor.x = boxWidth - line.width + shadowX;
					case TextAlign.Center: cursor.x = (boxWidth * 0.5) - (line.width * 0.5) + shadowX;
				}
			}
			else
				cursor.x = shadowX;
			
			canvas.g2.drawString(line.text, objectX + x + cursor.x - cameraX, objectY + y + cursor.y - cameraY);
						
			cursor.y += fontHeight + lineSpacing;
		}

		if (shadowAlpha != 1)
			canvas.g2.popOpacity();
		
		cursor.x = 0;
		cursor.y = 0;

		canvas.g2.color = color;

		if (alpha != 1)
			canvas.g2.pushOpacity(alpha);

		for (line in lines)
		{			
			if (boxWidth > 0)
			{
				switch (align)
				{
					case TextAlign.Left: cursor.x = 0;
					case TextAlign.Right: cursor.x = boxWidth - line.width;
					case TextAlign.Center: cursor.x = (boxWidth / 2) - (line.width / 2);
				}
			}
			
			canvas.g2.drawString(line.text, objectX + x + cursor.x - cameraX, objectY + y + cursor.y - cameraY);
						
			cursor.y += fontHeight + lineSpacing;
		}

		if (alpha != 1)
			canvas.g2.popOpacity();			
	}
}
