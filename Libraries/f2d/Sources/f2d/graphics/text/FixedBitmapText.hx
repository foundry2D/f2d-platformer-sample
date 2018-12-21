package f2d.graphics.text;

import kha.Image;
import kha.Canvas;
import kha.math.Vector2i;
import f2d.Graphic.ImageType;
import f2d.atlas.Atlas;
import f2d.atlas.Region;
import f2d.Object;

class FixedBitmapText extends Graphic
{    
    public var region:Region;
    public var text:String;
    
    var letterWidth:Int;
	var letterHeight:Int;
    
    public function new(source:ImageType, text:String, letterWidth:Int, letterHeight:Int):Void
    {
        super();
        
        switch (source.type)
		{
			case First(image):
				this.region = new Region(image, 0, 0, image.width, image.height);
			
			case Second(region):
				this.region = region;

            case Third(regionName):
                this.region = Atlas.getRegion(regionName);
		}        

        this.letterWidth = letterWidth;
        this.letterHeight = letterHeight;		
    }
    
    override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
        preRender(canvas.g2, objectX, objectY, cameraX, cameraY);

        canvas.g2.color = color;
        
        var code:Int;
        var cursor = objectX + x;
            
        text = text.toUpperCase();
        
        for (i in 0...text.length)
        {
            if (text.charAt(i) != ' ')
            {
                code = text.charCodeAt(i);
                if (code < 96)
                    code -= 33;
                else if (code > 122)
                    code -= 60;				
                
                canvas.g2.drawScaledSubImage(region.image, region.sx + (code * letterWidth), region.sy, letterWidth, letterHeight,
							 cursor - cameraX, objectY + y - cameraY, letterWidth, letterHeight);
            }
            
            cursor += letterWidth;
        }

        postRender(canvas.g2);        				
	}
	
	override public function getSize():Vector2i 
    {
        return new Vector2i(text.length * letterWidth, letterHeight);
    }
}
