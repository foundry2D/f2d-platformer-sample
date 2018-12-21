package f2d.filters;

/**
 * Ported from https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/brightnesscontrast.js
 */

import kha.Color;
import kha.Shaders;
import kha.Canvas;
import kha.graphics4.ConstantLocation;
import f2d.util.ShaderTool;
import f2d.Sdg;

class BrightnessContrast extends Filter
{
	public var brightness(default, set):Float;
	public var contrast(default, set):Float;

	var brightnessID:ConstantLocation;
	var contrastID:ConstantLocation;

	public function new(brightness:Float = 0, contrast:Float = 0):Void
	{
		super();

		pipeline = ShaderTool.createPipeline(ShaderTool.IMAGE_SHADER, Shaders.brightness_contrast_frag);

		brightnessID = pipeline.getConstantLocation('brightness');
		contrastID = pipeline.getConstantLocation('contrast');

		this.brightness = brightness;
		this.contrast = contrast;
	}

	override public function apply(canvas:Canvas):Void
	{
		canvas.g2.begin(false);

		//canvas.g2.color = Color.White;

		canvas.g2.pipeline = pipeline;
		canvas.g4.setFloat(brightnessID, brightness);
		canvas.g4.setFloat(contrastID, contrast);

		canvas.g2.drawImage(Filter.texture, 0, 0);

		canvas.g2.pipeline = null;

		canvas.g2.end();
	}

	function set_brightness(value:Float):Float
	{
		brightness = Sdg.clamp(value, -1, 1);

		return brightness;
	}

	function set_contrast(value:Float):Float
	{
		contrast = Sdg.clamp(value, -1, 1);

		return contrast;
	}
}
