@tool # so that we see the words in the editor

extends GridContainer

signal word_selected(correct: bool)

@export var words: Array[String] :
	set (value):
		print(value)
		words = value
		reset()

@export var shuffle:bool = true
@export_file() var texture:String
@export_file() var correctTexture:String

const STATUS_INCOMPLETE:int = 0
const STATUS_PASSED:int = 1

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
		var textureRect: = TextureRect.new()
		textureRect.set_meta("status", STATUS_INCOMPLETE)
		textureRect.texture = load(texture) as Texture2D
		add_child(textureRect)

		var label: = Label.new()
		label.text = word
		textureRect.add_child(label)
