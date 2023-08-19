@tool

# Maybe there is a bug if the shader export has a default load() ?
# For some reason that default gets loaded even if the shader was removed in the UI.

class_name HoverButton extends TextureButton

@export var center_pivot: = true
@export var hover_pointer: = true
@export var hover_scale: = 1.2
@export var tween_duration: = 0.25
@export var transition: Tween.TransitionType = Tween.TRANS_BACK
@export var ease_hover: Tween.EaseType = Tween.EASE_OUT
@export var ease_out: Tween.EaseType = Tween.EASE_IN
@export var disabled_shader: Shader = load("res://src/shaders/grayscale.gdshader") as Shader

var _scale = scale
var _shader_material: ShaderMaterial
var _disabled_shader_material: ShaderMaterial

# _set is only called if properties are changed from the outside
func _set(property: StringName, value: Variant) -> bool:
	match property:
		"disabled":
			if value == false:
				material = _shader_material
				mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			elif _disabled_shader_material:
				material = _disabled_shader_material
				mouse_default_cursor_shape = Control.CURSOR_ARROW

	return false # false: property is handled normally; true: property processing stops


func _ready() -> void:
	if hover_pointer:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if center_pivot:
		pivot_offset = size / 2

	_shader_material = material as ShaderMaterial

	if disabled_shader:
		_disabled_shader_material = ShaderMaterial.new()
		_disabled_shader_material.shader = disabled_shader

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if disabled:
		return

	(create_tween()
		.tween_property(
			self,
			"scale",
			_scale + Vector2.ONE * hover_scale - Vector2.ONE, tween_duration,
		)
		.set_trans(transition)
		.set_ease(ease_hover)
	)


func _on_mouse_exited() -> void:
	if disabled:
		return

	(create_tween()
		.tween_property(self, "scale", _scale, tween_duration)
		.set_trans(transition)
		.set_ease(ease_out)
	)
