# F2D
2D Engine Core of foundry based on [Sdg](https://github.com/RafaelOliveira/sdg)

This is a 2D engine for Kha. The api is being developed and it can change, but it is already in a good state.

[showcase](https://github.com/RafaelOliveira/sdg-showcase) | [samples](https://github.com/RafaelOliveira/sdg-samples)

Main features:

Game objects are represented by the class Object, and it can have one of the graphic class:

- Sprites
- TileSprite (a sprite with a seamless texture that can scroll inside)
- NinePatch
- Tilemap
- GraphicList (can hold many graphic classes together)
- Text and BitmapText
- Shapes
- Particles

There is a basic entity-component system, you can create generic components that can be updated with the objects.
Components available:
- Animator (for spritesheet animations)
- Motion (for velocity, acceleration and drag)
- OnClick (for a basic click event)

Images can be used as a single file, or it can be used inside an atlas.
Softwares supported: TexturePacker and Shoebox

There is no code for tweens, but there is support to use the library [Delta](https://github.com/furusystems/Delta).

There is a collision system for rectangle objects and tilemaps, but it needs more testing.

Documentation and a tutorial are planned.

TODO:
- Screen transitions
- Shaders
