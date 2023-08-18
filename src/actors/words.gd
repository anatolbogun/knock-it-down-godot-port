@tool # so that we see the words in the editor

extends GridContainer

# It might be better to change the texture not via the disabled texture because then we can't
# disable any button without a visual change.

signal word_clicked(word:String, button: TextureButton, label: Label)

@export var words: Array[String] :
	set (value):
		words = value
		reset()

@export var shuffle:bool = true :
	set (value):
		shuffle = value
		reset()

@export var texture:Texture2D
@export var correct_texture:Texture2D
@export var tween_offset:Vector2 = Vector2(0, -683)

var buttons:Array[TextureButton]

# _set is only called if properties are changed from the outside
#func _set(property: StringName, value: Variant) -> bool:
	#match property:
		#"disabled":
			#if value == true:
				#button.mouse_default_cursor_shape = Control.CURSOR_ARROW
#
	#return false # false: property is handled normally; true: property processing stops


func _enter_tree() -> void:
	reset()


func reset() -> void:
	if !is_inside_tree():
		return

	for child in get_children():
		child.queue_free()

	var _words = words.duplicate()
	buttons.clear()

	if shuffle:
		_words.shuffle()

	for word in _words:
		var button: = TextureButton.new()
		button.texture_normal = texture
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		if !Engine.is_editor_hint():
			button.modulate.a = 0

		add_child(button)

		var label: = Label.new()
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.text = word
		button.add_child(label)

		button.mouse_entered.connect(func () -> void:
			label.add_theme_color_override(
				"font_color",
				theme.get_color("font_hover_color", "Label")
			)
		)

		button.mouse_exited.connect(func () -> void:
			label.remove_theme_color_override("font_color")
		)

		button.pressed.connect(func () -> void: word_clicked.emit(word, button, label))

		buttons.push_back(button)

	# store target_position on sort_children signal because earlier the parent GridContainer's
	# positioning hasn't happened yet (this may run several times which is unnecessary, but should
	# be negligible)
	sort_children.connect(
		func () -> void:
			for button in buttons:
				button.set_meta("target_position", button.position)

				if !Engine.is_editor_hint():
					button.position += tween_offset
	)


func mark_correct(button:TextureButton) -> void:
	button.disabled = true
	button.texture_normal = correct_texture

	# I'd prefer a common Button class that handles cursors with _set to observe the disabled state
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW


func show_items() -> Tween:
	var tween: = (
		create_tween()
			.set_parallel()
			.set_ease(Tween.EASE_OUT)
			.set_trans(Tween.TRANS_BOUNCE)
	)

	var stagger: = 0.1
	var i: = 0

	buttons.sort_custom(
		func (a:TextureButton, b:TextureButton) -> bool:
			return a.position.y > b.position.y
	)

	for button in buttons:
		var target_position = button.get_meta("target_position")

		(
			tween
			.tween_property(button, "modulate:a", 1, 0.25)
			.set_delay(i * stagger)
		)

		(
			tween
			.tween_property(button, "position", target_position, 1)
			.set_delay(i * stagger)
		)

		i += 1

	return tween
