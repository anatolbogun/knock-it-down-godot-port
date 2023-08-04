@tool # so that we see the words in the editor

extends GridContainer

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

func _enter_tree() -> void:
	reset()

func reset() -> void:
	if !is_inside_tree():
		return

	for child in get_children():
		child.queue_free()

	var _words = words.duplicate()

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
