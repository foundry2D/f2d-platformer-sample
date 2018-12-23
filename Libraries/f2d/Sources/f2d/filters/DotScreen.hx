package f2d.filters;

/**
 * Ported from https://github.com/evanw/glfx.js/blob/master/src/filters/fun/dotscreen.js
 */

import kha.Shaders;
import kha.Canvas;
import kha.math.FastVector2;
import kha.graphics4.ConstantLocation;
import f2d.util.ShaderTool;
import f2d.F2d;

class DotScreen extends Filter
{
	var resolution:FastVector2;	
	public var angle:Float;
	public var scale:Float;

	var resolutionID:ConstantLocation;
	var angleID:ConstantLocation;
	var scaleID:ConstantLocation;

	public function new():Void
	{
		super();

		pipeline = ShaderTool.createPipeline(ShaderTool.IMAGE_SHADER, Shaders.dot_screen_frag);

		resolutionID = pipeline.getConstantLocation('resolution');
		angleID = pipeline.getConstantLocation('angle');
		scaleID = pipeline.getConstantLocation('scale');

		resolution = new FastVector2(F2d.gameWidth, F2d.gameHeight);
		angle = 5;
		scale = 1;    	
	}

	override public function apply(canvas:Canvas):Void
	{
		canvas.g2.begin(false);		

		canvas.g2.pipeline = pipeline;
		canvas.g4.setVector2(resolutionID, resolution);
		canvas.g4.setFloat(angleID, angle);
		canvas.g4.setFloat(scaleID, scale);

		canvas.g2.drawImage(Filter.texture, 0, 0);

		canvas.g2.pipeline = null;

		canvas.g2.end();
	}
}
