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

@export_file() var texture:String
@export_file() var correct_texture:String

var buttons:Array[TextureButton]

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
		button.texture_normal = load(texture) as Texture2D
		button.texture_disabled = load(correct_texture) as Texture2D
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		add_child(button)

		var label: = Label.new()
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.text = word
		button.add_child(label)

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
					button.position.y = button.position.y - get_viewport_rect().size.y
	)

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
			.tween_property(button, "position", target_position, 1)
			.set_delay(i * stagger)
		)

		i += 1

	return tween
