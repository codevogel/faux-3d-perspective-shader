# Faux 3D Perspective Shader for 2D Canvas Items in Godot

(originally released on [Godot Shaders](https://godotshaders.com/shader/faux-3d-perspective-shader-for-2d-canvas-items/))

## WHAT IS IT?
An improvement on [Hei's 2d-perspective shader](https://godotshaders.com/shader/2d-perspective/).

The most important difference to note in this shader are:
- This shader uses updated syntax (Compatible with Godot 4.4+)
- It adds a parameter 'use_front' that allows for the Canvas Item to have a front and the back side. 
- The UV's will scale so the textures are applied as you would expect any other 3D object to behave.
- It adds an example use case script for simulating 3D cards in a 2D card game.

## EFFECT

![Effect Demo](./github-assets/example_effect.gif)

## USAGE

See the EXAMPLE PROJECT on GitHub, or the below example script that uses this shader for simulating 3D cards in a 2D card game, so we can use Controls like the HBoxContainer to organise the layout of our cards

1. Create a new Shader and copy the shader code into it.
2. Create a new ShaderMaterial and assign the Shader to it.
3. Create a new TextureRect node and assign the ShaderMaterial to its Material property.
4. Attach the example script below to the TextureRect node.
5. Assign the front and back textures to the script's exported properties.

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
