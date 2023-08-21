@tool # so that we see the words in the editor

# Notes:
# There's a nicer way to handle button hover mouse cursors and possibly hover label colours with a
# common Button class that handles this with _set to observe the disabled state.

extends GridContainer

signal word_clicked(word:String, button: TextureButton)

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
@export var hover_audio:AudioStream

var buttons:Array[TextureButton]

var disabled:bool = false :
	set(value):
		for button in buttons:
			button.disabled = value || button.texture_normal == correct_texture

			if button.disabled:
				button.mouse_default_cursor_shape = Control.CURSOR_ARROW
			else:
				button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _ready() -> void:
	$AudioStreamPlayer.stream = hover_audio


func _enter_tree() -> void:
	reset()


func reset() -> void:
	if !is_inside_tree():
		return

	for child in get_children():
		if child is Control:
			child.queue_free()

	var _words = words.duplicate()
	buttons.clear()

	if shuffle:
		_words.shuffle()

	for word in _words:
		var button: = TextureButton.new()
		button.texture_normal = texture
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pivot_offset = button.size / 2

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
			if button.disabled:
				return

			$AudioStreamPlayer.play()

			label.add_theme_color_override(
				"font_color",
				theme.get_color("font_hover_color", "Label")
			)
		)

		button.mouse_exited.connect(func () -> void:
			label.remove_theme_color_override("font_color")
		)

		button.pressed.connect(func () -> void: word_clicked.emit(word, button))

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
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW

	for child in button.get_children():
		child.queue_free()


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


func hit_and_destroy() -> Signal:
	var min_offset: = Vector2(-200, -250)
	var max_offset: = Vector2(200, -350)
	var min_rotation: = -90.0
	var max_rotation: = 90.0
	var ground_position: = 300.0

	var hit_tween: = (
		create_tween()
			.set_parallel()
			.set_ease(Tween.EASE_OUT)
			.set_trans(Tween.TRANS_SINE)
	)

	for button in buttons:
		var offset = Vector2(
			randf_range(min_offset.x, max_offset.x),
			randf_range(min_offset.y, max_offset.y),
		)

		hit_tween.tween_property(button, "position", offset, 0.25).as_relative()
		hit_tween.tween_property(
			button,
			"rotation_degrees",
			randf_range(min_rotation, max_rotation),
			0.25,
		)

	await hit_tween.finished
	await get_tree().create_timer(0.25).timeout

	var fall_tween: = (
		create_tween()
			.set_parallel()
			.set_ease(Tween.EASE_IN)
			.set_trans(Tween.TRANS_SINE)
	)

	for button in buttons:
		fall_tween.tween_property(button, "position:y", ground_position, 0.5)

	return fall_tween.finished
