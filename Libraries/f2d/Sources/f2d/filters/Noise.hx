package f2d.filters;

/**
 * Ported from https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/noise.js
 */

import kha.Color;
import kha.Shaders;
import kha.Canvas;
import kha.graphics4.ConstantLocation;
import f2d.util.ShaderTool;
import f2d.F2d;

class Noise extends Filter
{
	public var amount(default, set):Float;	
	var amountID:ConstantLocation;

	public function new():Void
	{
		super();

		pipeline = ShaderTool.createPipeline(ShaderTool.IMAGE_SHADER, Shaders.noise_frag);

		amountID = pipeline.getConstantLocation('amount');
		amount = 0.5;		
	}

	override public function apply(canvas:Canvas):Void
	{
		canvas.g2.begin(false);

		//canvas.g2.color = Color.White;

		canvas.g2.pipeline = pipeline;
		canvas.g4.setFloat(amountID, amount);		

		canvas.g2.drawImage(Filter.texture, 0, 0);

		canvas.g2.pipeline = null;

		canvas.g2.end();
	}

	function set_amount(value:Float):Float
	{
		amount = F2d.clamp(value, 0, 1);

		return amount;
	}
}
