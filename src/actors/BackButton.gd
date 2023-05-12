extends TextureButton

func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	(create_tween()
		.tween_property(self, "scale", Vector2(1.5, 1.5), 0.25)
		.set_trans(Tween.TRANS_BACK)
		.set_ease(Tween.EASE_OUT)
	)


func _on_mouse_exited() -> void:
	(create_tween()
		.tween_property(self, "scale", Vector2(1, 1), 0.25)
		.set_trans(Tween.TRANS_BACK)
		.set_ease(Tween.EASE_IN)
	)
