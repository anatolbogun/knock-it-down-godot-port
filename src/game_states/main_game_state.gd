extends Node2D

@export var narrator_audio_path: = "assets/audio/narrator/"
@export var narrator_audio_prefix: = "find_the_word_"
@export var narrator_audio_extension: = ".mp3"

var words:Array
var target:Dictionary

func _enter_tree() -> void:
	words = $Control/Words.words.map(func (word) -> Dictionary:
		return {
			"word": word,
			"audio_resource": load(
				"res://"
				+ narrator_audio_path
				+ narrator_audio_prefix
				+ word
				+ narrator_audio_extension
			),
		}
	)

	words.shuffle()
	next_round()

func _on_audio_button_pressed() -> void:
	if target:
		$AudioStreamPlayer.stream = target.audio_resource
		$AudioStreamPlayer.play()

func _on_words_word_clicked(word:String, button:TextureButton, label:Label) -> void:
	if word == target.word:
		button.disabled = true
		label.queue_free()
		next_round()

func next_round() -> void:
	var next_word = words.pop_back()

	if !next_word:
		game_over()
		return

	target = next_word
	print("Target word: ", target.word)

func game_over() -> void:
	print("Game over")
