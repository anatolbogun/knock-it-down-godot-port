@tool

extends Node2D

@export var body_texture:Texture2D = load("res://assets/spritesheets/furball_purple.sprites/body.tres")


func _ready() -> void:
	$Body.texture = body_texture
	idle()

func idle() -> void:
	await get_tree().create_timer(randf_range(0, 2)).timeout
	$AnimationPlayer.play("idle")

func jump() -> void:
	await get_tree().create_timer(randf_range(0, 0.25)).timeout
	$AnimationPlayer.play("jump")
	await $AnimationPlayer.animation_finished
	idle()

func laugh() -> void:
	$AnimationPlayer.play("laugh")
	await $AnimationPlayer.animation_finished
	idle()

