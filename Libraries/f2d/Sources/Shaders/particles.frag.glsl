#version 450

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

void kore() {
	vec4 texcolor = texture(tex, texCoord);	
	FragColor = vec4(
        texcolor.r * texcolor.a * color.r,
        texcolor.g * texcolor.a * color.g,
        texcolor.b * texcolor.a * color.b,
        texcolor.a * color.a
    );
}