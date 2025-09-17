# Faux 3D Perspective Shader for 2D Canvas Items in Godot

(originally released on [Godot Shaders](https://godotshaders.com/shader/faux-3d-perspective-shader-for-2d-canvas-items/))

## WHAT IS IT?

An improvement on [Hei's 2d-perspective shader](https://godotshaders.com/shader/2d-perspective/).

The most important difference to note in this shader are:
- This shader uses updated syntax (Compatible with Godot 4.4+)
- It adds a parameter 'use_front' that allows for the Canvas Item to have a front and the back side. 
- The UV's will scale so the textures are applied as you would expect any other 3D object to behave.
- It adds an example use case script for simulating 3D cards in a 2D card game, which uses the shader applied on a SubViewportContainer, allowing you to layout the cards with 2D UI elements while retaining their 3D looks.

The shader code can be found [here](./example/shader/faux_3d_perspective_shader.gdshader).

## EFFECT

![Effect Demo](./github-assets/example_effect.gif)

## USAGE

**The best way to explore this shader's usage is to clone this project and open it in Godot 4.4+.**

### General Usage

1. Create a new ShaderMaterial and assign this shader to it.
2. Apply the ShaderMaterial to a CanvasItem, such as a TextureRect or SubViewportContainer.
3. Adjust the shader parameters to achieve the desired perspective effect.

### Card Game Example

1. Create a new SubViewportContainer node.
2. Add a SubViewport as a child of the SubViewportContainer.
3. Add a VBoxContainer as a child of the SubViewport.
4. Add a TextureRect as a child of the VBoxContainer. This will be used to display the card art.
5. Add a CardContents node as a child of the VBoxContainer. This will be used to display any UI elements on the card.
6. Add any Controls of your liking to the CardContents node.
7. Assign the Faux 3D Perspective shader to a ShaderMaterial and assign it to the SubViewportContainer's material property.


See the `Card.gd` script below for an example of how to control the shader parameters and switch between front and back art based on rotation.
The latest version can be found in [Card.gd](./example/card.gd), but here is a copy for convenience:

```gdscript
# An example of a simulating a 3D card with a 2D TextureRect
# using the Faux 3D Perspective shader by CodeVogel (https://github.com/codevogel/faux-3d-perspective-shader-godot)
@tool
extends SubViewportContainer
class_name Card

@export var front_art: Texture2D = preload("uid://d0cdfxs15e68h"):
	set(value):
		front_art = value
		_refresh()
@export var back_art: Texture2D = preload("uid://d2qctukn38v5q"):
	set(value):
		back_art = value
		_refresh()
@export var cull_backface: bool = false

@onready var art_texture_rect: TextureRect = $SubViewport/ArtTextureRect
@onready var card_contents: Control = $SubViewport/CardContents

@export_range(1, 120, 1) var simulated_camera_fov: float = 60:
	set(value):
		simulated_camera_fov = value
		_refresh()
@export_range(-360, 360, 1) var rotation_y: float = 0.0:
	set(value):
		rotation_y = value
		_refresh()
@export_range(-360, 360, 1) var rotation_x: float = 0.0:
	set(value):
		rotation_x = value
		_refresh()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not front_art:
		warnings.append("Front art texture is not assigned.")
	if cull_backface:
		if back_art:
			warnings.append(
				"Back art texture will not be visible because backface culling is enabled."
			)
	elif not back_art:
		warnings.append("Back art texture is not assigned.")
	if not (material is ShaderMaterial):
		warnings.append("CardArt requires a ShaderMaterial to function properly.")
	return warnings


func _ready():
	if not Engine.is_editor_hint():
		_refresh()


func _refresh():
	if not (material is ShaderMaterial):
		return
	if not card_contents or not art_texture_rect:
		return
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("rot_y_deg", rotation_y)
	shader_material.set_shader_parameter("rot_x_deg", rotation_x)
	shader_material.set_shader_parameter("cull_backface", cull_backface)
	shader_material.set_shader_parameter("fov", simulated_camera_fov)
	_refresh_texture()


func _refresh_texture():
	if not front_art or not back_art:
		return

	var rot_x_deg = wrapf(rotation_x, 0, 360)
	var rot_y_deg = wrapf(rotation_y, 0, 360)
	var front_facing_over_x = rot_x_deg < 90 or rot_x_deg > 270
	var front_facing_over_y = rot_y_deg < 90 or rot_y_deg > 270
	var use_front = front_facing_over_y == front_facing_over_x
	card_contents.visible = use_front
	art_texture_rect.texture = front_art if use_front else back_art
	material.set_shader_parameter("use_front", use_front)
```

## LICENSE

MIT License

See the [Example Project on GitHub](https://github.com/codevogel/faux-3d-perspective-shader) for more details.
