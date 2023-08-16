@tool

# CONTINUE HERE
# - Not sure if this needs to be a tool because main_gme_state overwrites the
#   default text.
# - Add description audio.
# - Probably add an optional background color and texture rect.
# - Find a way to disable or catch clicks.

extends VBoxContainer

signal completed

@export_file() var title_image:String
@export_multiline var description:String
@export_file() var description_audio:String
@export var auto_show:bool = true


func _ready() -> void:
	size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)

	$Title.texture = load(title_image) as Texture2D
	$Description.text = description

	if auto_show:
		visible = true


func _on_start_button_button_down() -> void:
	var tween: = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)
	tween.tween_callback(
		func () -> void:
			completed.emit()
			queue_free()
	)

