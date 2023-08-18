@tool

# CONTINUE HERE
# - Probably add an optional background color and texture rect.
# - Find a way to disable or catch clicks.

extends VBoxContainer

signal completed

@export_file() var title_image:String
@export_multiline var description:String
@export var title_audio: AudioStream
@export var description_audio: AudioStream


func _ready() -> void:
	# hide this in the editor unless we open this scene file itself
	visible = !owner || !Engine.is_editor_hint()

	size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)

	$Title.texture = load(title_image) as Texture2D
	$Description.text = description

	print("Engine.is_editor_hint() ", Engine.is_editor_hint())

	if !Engine.is_editor_hint() && ( title_audio || description_audio ):
		$StartButton.disabled = true

		if title_audio:
			$AudioStreamPlayer.stream = title_audio
			$AudioStreamPlayer.play()
			await $AudioStreamPlayer.finished

		if description_audio:
			$AudioStreamPlayer.stream = description_audio
			$AudioStreamPlayer.play()
			await $AudioStreamPlayer.finished

		$StartButton.disabled = false


func _on_start_button_button_down() -> void:
	var tween: = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)
	tween.tween_callback(
		func () -> void:
			completed.emit()
			queue_free()
	)

