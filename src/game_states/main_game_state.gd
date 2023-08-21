extends Node2D

# Notes:
# - To reduce load/start times dramatically in Chrome (on Mac OS?), ensure that the use-angle flag
#   is set to "Metal"; chrome://flags/#use-angle . Hopefully, going forward this will become the
#  	default graphics backend, and/or Google will fix whatever takes so long with the browser default
#   OpenGL backend.
# - In order to use the project settings display/window/stretch/aspect: expand (which does not clip
#   the canvas), it's a good idea to add a camera that's centered to the viewport.

@export var narrator_audio_path: = "assets/audio/narrator/"
@export var narrator_audio_prefix: = "find_the_word_"
@export var narrator_audio_extension: = ".mp3"

@export var sfx_audio_path: = "assets/audio/sfx/"
@export var sfx_audio_extension: = ".mp3"

var words:Array
var target:Dictionary
var is_game_over:bool
var _yeti_position:Vector2


func _enter_tree() -> void:
	words = $Ui/Words.words.map(func (word) -> Dictionary:
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
	_yeti_position = $Yeti.position

	if !Engine.is_editor_hint():
		$SnowParticles.emitting = true
		$Yeti.visible = false

	# start the activity in case there is no IntroPanel
	if !$IntroPanel:
		start()


func start() -> void:
	$Ui/Words.disabled = true
	$CommonUi/AudioButton.disabled = true

	$Yeti.position.x = get_viewport_rect().size.x + 500
	$Yeti.visible = true
	$Yeti/AnimationPlayer.play("drive")

	var tween: = create_tween()

	(
		tween
		.tween_property(
			$Yeti,
			"position:x",
			_yeti_position.x,
			$Yeti/AnimationPlayer.current_animation_length
		)
	)

	await $Yeti/AnimationPlayer.animation_finished
	$Yeti/AnimationPlayer.play("break")
	await $Yeti/AnimationPlayer.animation_finished

	play_sfx("ice-build")
	await $Ui/Words.show_items().finished
	next_round()


func play_target_audio() -> Signal:
	if target:
		$NarratorStreamPlayer.stream = target.audio_resource
		$NarratorStreamPlayer.play()
		return $NarratorStreamPlayer.finished

	# return a signal that is emitted immediately
	return get_tree().create_timer(0).timeout


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


func _on_words_word_clicked(word:String, button:TextureButton) -> void:
	if is_game_over || !target.has("word"):
		return

	$Ui/Words.disabled = true
	$CommonUi/AudioButton.disabled = true

	$Yeti/AnimationPlayer.play("retract")
	await $Yeti/AnimationPlayer.animation_finished

	$Yeti/WreckingBallTarget.global_position = button.global_position + button.size / 2

	var tween: = create_tween()
	tween.tween_property($Yeti.get_modification_stack(), "strength", 1, 0.125)
	await tween.finished

	if word == target.word:
		correct(button)
	else:
		incorrect()

	var animation: = "correct" if word == target.word else "incorrect"

	if $CommonUi/Rounds.rounds_left == 0:
		animation = "RESET"

	$Yeti/AnimationPlayer.play(animation)
	await $Yeti/AnimationPlayer.animation_finished

	$Yeti/AnimationPlayer.play("RESET")

	var tween2: = create_tween().set_parallel()
	tween2.tween_property($Yeti/CraneWheelsBone2D/CraneBodyBone2D, "rotation", 0, 0.5)
	tween2.tween_property($Yeti.get_modification_stack(), "strength", 0, 0.5)

	if $CommonUi/Lives.lives_left > 0:
		next_round()


func correct(button:TextureButton) -> void:
	play_sfx(sample(["ice-break-1", "ice-break-2"]))
	$Ui/Words.mark_correct(button)
	$CommonUi/Rounds.pass_round()


func incorrect() -> void:
	play_sfx("incorrect")
	$CommonUi/Rounds.fail_round()
	$CommonUi/Lives.remove_life()


func next_round() -> void:
	var next_word = words.pop_back()

	if !next_word:
		game_over()
		return

	target = next_word
	print("Target word: ", target.word)

	await play_target_audio()

	$Ui/Words.disabled = false
	$CommonUi/AudioButton.disabled = false


func game_over() -> void:
	print("Game over")
	is_game_over = true
	$Ui/Words.disabled = true
	$CommonUi/AudioButton.disabled = true
	play_sfx("ice-break-finish")

	await $Ui/Words.hit_and_destroy()
	$Yeti/AnimationPlayer.play("success")


func _on_lives_died() -> void:
	print("You died.")
	is_game_over = true
	# TO DO: add failure animations for yeti and friends
