extends Node2D

# Note that to reduce load/start times dramatically in Chrome (on Mac OS?), ensure that the
# use-angle flag is set to "Metal"; chrome://flags/#use-angle . Hopefully, going forward this will
# become the default graphics backend, and/or Google will fix whatever takes so long with the
# browser default OpenGL backend.

@export var narrator_audio_path: = "assets/audio/narrator/"
@export var narrator_audio_prefix: = "find_the_word_"
@export var narrator_audio_extension: = ".mp3"

@export var sfx_audio_path: = "assets/audio/sfx/"
@export var sfx_audio_extension: = ".mp3"

var words:Array
var target:Dictionary
var is_game_over:bool

func _enter_tree() -> void:
	words = $Control/Words.words.map(func (word) -> Dictionary:
		return {
			"word": word,
			"audio_resource": load(
				"res://"
				+ narrator_audio_path
				+ narrator_audio_prefix
				+ word.to_lower()
				+ narrator_audio_extension
			),
		}
	)

	words.shuffle()

func _ready() -> void:
	is_game_over = false
	await get_tree().create_timer(1).timeout
	play_sfx("ice-build")
	await $Control/Words.show_items().finished
	next_round()

func play_target_audio() -> void:
	if target:
		$NarratorStreamPlayer.stream = target.audio_resource
		$NarratorStreamPlayer.play()

func play_sfx(key) -> AudioStreamPlayer:
	var resource_path:String = "res://" + sfx_audio_path + key + sfx_audio_extension
	var resource: = load(resource_path)

	if !resource:
		push_warning("Could not find the SFX resource ", resource_path)
		return

	# get_stream_playback() only returns an AudioStreamPlaybackPolyphonic when the AudioStreamPlayer
	# is playing; otherwise it'll crash.
	if !$SFXStreamPlayer2D.playing:
		$SFXStreamPlayer2D.play()

	var audioStreamPlaybackPolyphonic: AudioStreamPlaybackPolyphonic = $SFXStreamPlayer2D.get_stream_playback()

	if !audioStreamPlaybackPolyphonic:
		push_warning("Ensure $SFXStreamPlayer2D has an AudioStreamPolyphonic stream.")
		return

	audioStreamPlaybackPolyphonic.play_stream(resource)

	return $SFXStreamPlayer2D

func sample(array:Array) -> Variant:
	return array[randi() % array.size()]

func _on_audio_button_pressed() -> void:
	play_target_audio()

func _on_words_word_clicked(word:String, button:TextureButton, label:Label) -> void:
	if is_game_over || !target.has("word"):
		return

	if word == target.word:
		play_sfx(sample(["ice-break-1", "ice-break-2"]))
		button.disabled = true
		label.queue_free()
		$Control/Rounds.pass_round()
	else:
		play_sfx("incorrect")
		$Control/Rounds.fail_round()
		$Control/Lives.remove_life()

	if $Control/Lives.lives_left > 0:
		next_round()

func next_round() -> void:
	var next_word = words.pop_back()

	if !next_word:
		game_over()
		return

	target = next_word
	print("Target word: ", target.word)

	play_target_audio()

func game_over() -> void:
	print("Game over")
	is_game_over = true
	play_sfx("ice-break-finish")

func _on_lives_died() -> void:
	print("You died.")
	is_game_over = true
