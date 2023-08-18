@tool # so that we see the lives in the editor

extends HFlowContainer

signal died()
signal life_added()
signal life_removed()


@export var num_lives:int = 3 :
	set(value):
		num_lives = value
		reset()

@export var life_texture:Texture2D
@export var death_texture:Texture2D

## number of lives left
var lives_left:int :
	get:
		return get_children().filter(
			func (child:Node) -> bool: return child.get_meta("status") == STATUS_ALIVE
		).size()

## number of total lives (lives + deaths)
var total_lives: int :
	get:
		return get_children().filter(
			func (child:Node) -> bool:
				return (
					child.get_meta("status") == STATUS_ALIVE
					|| child.get_meta("status") == STATUS_DEAD
				)
		).size()

const STATUS_ALIVE:int = 0
const STATUS_DEAD:int = 1


func _enter_tree() -> void:
	reset()


func reset() -> void:
	if !is_inside_tree():
		return

	for child in get_children():
		child.queue_free()

	for num_life in num_lives:
		add_life()


## adds a life by either changing a dead life into an alive life, or by adding an extra life
func add_life() -> void:
	var dead_lives:Array[Node] = get_children().filter(
		func (child:Node) -> bool: return child.get_meta("status") == STATUS_DEAD
	) as Array[Node]

	var _life:TextureRect

	if dead_lives.is_empty():
		_life = TextureRect.new()
		add_child(_life)
	else:
		_life = dead_lives.front() as TextureRect

	_life.set_meta("status", STATUS_ALIVE)
	_life.texture = life_texture

	life_added.emit()


## removes a life and emits the died signal if all lives are gone
func remove_life() -> void:
	var alive_lives:Array[Node] = get_children().filter(
		func (child:Node) -> bool: return child.get_meta("status") == STATUS_ALIVE
	) as Array[Node]

	if alive_lives.is_empty():
		return

	var _life: = alive_lives.back() as Node
	_life.set_meta("status", STATUS_DEAD)
	_life.texture = death_texture

	life_removed.emit()

	if alive_lives.size() <= 1:
		died.emit()
