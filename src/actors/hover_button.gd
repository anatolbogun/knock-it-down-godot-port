class_name HoverButton extends TextureButton

@export var center_pivot: = true
@export var hover_pointer: = true
@export var hover_scale: = 1.2
@export var tween_duration: = 0.25
@export var transition: Tween.TransitionType = Tween.TRANS_BACK
@export var ease_hover: Tween.EaseType = Tween.EASE_OUT
@export var ease_out: Tween.EaseType = Tween.EASE_IN


func _ready() -> void:
	if hover_pointer:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if center_pivot:
		pivot_offset = size / 2

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	(create_tween()
		.tween_property(self, "scale", Vector2(hover_scale, hover_scale), tween_duration)
		.set_trans(transition)
		.set_ease(ease_hover)
	)


func _on_mouse_exited() -> void:
	(create_tween()
		.tween_property(self, "scale", Vector2(1, 1), tween_duration)
		.set_trans(transition)
		.set_ease(ease_out)
	)
