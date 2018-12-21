package f2d.filters;

/**
 * Ported from https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/huesaturation.js
 */

import kha.Color;
import kha.Shaders;
import kha.Canvas;
import kha.graphics4.ConstantLocation;
import f2d.util.ShaderTool;
import f2d.Sdg;

class HueSaturation extends Filter
{
	public var hue(default, set):Float;
	public var saturation(default, set):Float;

	var hueID:ConstantLocation;
	var saturationID:ConstantLocation;

	public function new(hue:Float = 0, saturation:Float = 0):Void
	{
		super();

		pipeline = ShaderTool.createPipeline(ShaderTool.IMAGE_SHADER, Shaders.hue_saturation_frag);

		hueID = pipeline.getConstantLocation('hue');
		saturationID = pipeline.getConstantLocation('saturation');

		this.hue = hue;
		this.saturation = saturation;
	}

	override public function apply(canvas:Canvas):Void
	{
		canvas.g2.begin(false);

		//canvas.g2.color = Color.White;

		canvas.g2.pipeline = pipeline;
		canvas.g4.setFloat(hueID, hue);
		canvas.g4.setFloat(saturationID, saturation);

		canvas.g2.drawImage(Filter.texture, 0, 0);

		canvas.g2.pipeline = null;

		canvas.g2.end();
	}

	function set_hue(value:Float):Float
	{
		hue = Sdg.clamp(value, -1, 1);

		return hue;
	}

	function set_saturation(value:Float):Float
	{
		saturation = Sdg.clamp(value, -1, 1);

		return saturation;
	}
}
