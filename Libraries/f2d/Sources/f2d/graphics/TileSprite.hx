package f2d.graphics;

import kha.Image;
import kha.Canvas;
import kha.math.Vector2;
import kha.math.Vector2i;
import f2d.atlas.Atlas;
import f2d.atlas.Region;
import f2d.Graphic.ImageType;

class TileSprite extends Graphic
{
    public var region(default, set):Region;

    public var width:Int;
    public var height:Int;

    var tileInfo:Array<Float>;
    var numTiles:Int;

    public var scrollX:Float;    
    public var scrollY:Float;

    var cursor:Vector2;
    
    public function new(source:ImageType, width:Int, height:Int, scrollX:Float = 0, scrollY:Float = 0):Void
    {
        super();

        cursor = new Vector2();

        switch (source.type)
		{
			case First(image):
				this.region = new Region(image, 0, 0, image.width, image.height);
			
			case Second(region):
				this.region = region;

			case Third(regionName):
				this.region = Atlas.getRegion(regionName); 
		}

        this.width = width;
        this.height = height;
        
        this.scrollX = scrollX;
        this.scrollY = scrollY;
        
        updateTileInfo();
    }

    override function update():Void
    {
        if (scrollX != 0)
        {
            cursor.x += scrollX;

            if (cursor.x > region.w)
                cursor.x = 0;
            else if (cursor.x < 0)
                cursor.x = region.w;
        }
        
        if (scrollY != 0)
        {
            cursor.y += scrollY;

            if (cursor.y > region.h)
                cursor.y = 0;
            else if (cursor.y < 0)
                cursor.y = region.h;
        }
    }

    function updateTileInfo():Void
    {
        cursor.x = -region.w;
        cursor.y = -region.h;

        tileInfo = new Array<Float>();

        while(cursor.y <= height)
        {
            while(cursor.x <= width)
            {
                tileInfo.push(cursor.x);
                tileInfo.push(cursor.y);

                cursor.x += region.w;
                numTiles++;
            }

            cursor.x = -region.w;
            cursor.y += region.h;
        }

        cursor.x = 0;
        cursor.y = 0;
    }
    
    override function render(canvas:Canvas, objectX:Float, objectY:Float, cameraX:Float, cameraY:Float):Void 
	{
        preRender(canvas.g2, objectX, objectY, cameraX, cameraY);

        var currTileX = 0.0;
        var currTileY = 0.0;

        var posX:Int;
        var posY:Int;

        var sx:Float;
        var sy:Float;
        var w:Int;
        var h:Int;

        canvas.g2.color = color;

        for (i in 0...tileInfo.length)
        {
            posX = i * 2;
            posY = (i * 2) + 1;

            sx = region.sx;
            sy = region.sy;
            w = region.w;
            h = region.h;            

            if ((tileInfo[posX] + cursor.x > width) || (tileInfo[posY] + cursor.y > height))
                continue;
            else
            {
                if (tileInfo[posX] < 0)
                {
                    sx = region.sx + region.w - cursor.x;

                    if (cursor.x < width)
                        w = Std.int(cursor.x);
                    else
                        w = width;

                    currTileX = objectX + x;
                }
                else 
                {
                    if (tileInfo[posX] + region.w + cursor.x > width)                    
                        w = Std.int(width - (tileInfo[posX] + cursor.x));
                    
                    currTileX = objectX + x + tileInfo[posX] + cursor.x;
                }

                if (tileInfo[posY] < 0)
                {
                    sy = region.sy + region.h - cursor.y;

                    if (cursor.y < height)
                        h = Std.int(cursor.y);
                    else
                        h = height;
                        
                    currTileY = objectY + y;
                }
                else 
                {
                    if (tileInfo[posY] + region.h + cursor.y > height)                    
                        h = Std.int(height - (tileInfo[posY] + cursor.y));

                    currTileY = objectY + y + tileInfo[posY] + cursor.y;
                }                    
            }
                        
            canvas.g2.drawScaledSubImage(region.image, sx, sy, w, h,
                currTileX - cameraX, currTileY - cameraY, w, h);                        
        }

        postRender(canvas.g2);
	}
    
    override public function getSize():Vector2i 
    {
        return new Vector2i(width, height);
    }

    function set_region(value:Region):Region
    {
        region = value;
        updateTileInfo();

        return value;
    }
}
