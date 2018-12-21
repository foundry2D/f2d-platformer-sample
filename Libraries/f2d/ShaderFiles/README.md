Kha always include all shaders files that are in the project, even if they are not used. 
The files are converted to the format of the target and embedded in the binary / js file.
So to prevent the increase of the output, the shaders files used by you project needs to be copied manually from this folder
to the shader folder of you project.

The files are:

Filters:  
brightness_contrast.frag.glsl  
dot_screen.frag.glsl  
hue_saturation.frag.glsl  
noise.frag.glsl