package f2d.util;

import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.BlendingFactor;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.FragmentShader;

class ShaderTool
{
	public inline static var IMAGE_SHADER:Int = 0;
	public inline static var COLOR_SHADER:Int = 1;
	public inline static var FONT_SHADER:Int = 2;

	public static function createPipeline(type:Int, fragmentShader:FragmentShader):PipelineState
	{
		var pipeline = new PipelineState();
		pipeline.fragmentShader = fragmentShader;

		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float3);
		
		switch(type)
		{
			case IMAGE_SHADER:
				pipeline.vertexShader = Shaders.painter_image_vert;
				
				structure.add("texPosition", VertexData.Float2);
				structure.add("vertexColor", VertexData.Float4);

			case COLOR_SHADER:
				pipeline.vertexShader = Shaders.painter_colored_vert;
				
				structure.add("vertexColor", VertexData.Float4);

			case FONT_SHADER:
				pipeline.vertexShader = Shaders.painter_text_vert;
				
				structure.add("texPosition", VertexData.Float2);
				structure.add("vertexColor", VertexData.Float4);

			default: return null;
		}

		pipeline.inputLayout = [structure];

		pipeline.blendSource = BlendingFactor.SourceAlpha;
		pipeline.blendDestination = BlendingFactor.InverseSourceAlpha;
		pipeline.alphaBlendSource = BlendingFactor.SourceAlpha;
		pipeline.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;

		pipeline.compile();

		return pipeline;
	}
}
