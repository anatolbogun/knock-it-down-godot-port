@tool # so that we see the rounds in the editor

extends HFlowContainer

signal died()
signal life_added()
signal life_removed()


@export var numLives:int = 3 :
	set(value):
		numLives = value
		reset()

@export_file() var lifeTexture:String
@export_file() var deathTexture:String

## number of lives left
var livesLeft:int :
	get:
		return get_children().filter(
			func (child:Node) -> bool: return child.get_meta("status") == STATUS_ALIVE
		).size()

## number of total lives (lives + deaths)
var totalLives: int :
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

	for numLife in numLives:
		add_life()

## adds a life by either changing a dead life into an alive life, or by adding an extra life
func add_life() -> void:
	var deadLives:Array[Node] = get_children().filter(
		func (child:Node) -> bool: return child.get_meta("status") == STATUS_DEAD
	) as Array[Node]

	var _life:TextureRect

	if (deadLives.is_empty()):
		_life = TextureRect.new()
		add_child(_life)
	else:
		_life = deadLives.front() as TextureRect

	_life.set_meta("status", STATUS_ALIVE)
	_life.texture = load(lifeTexture) as Texture2D

	life_added.emit()

## removes a life and emits the died signal if all lives are gone
func remove_life() -> void:
	var aliveLives:Array[Node] = get_children().filter(
		func (child:Node) -> bool: return child.get_meta("status") == STATUS_ALIVE
	) as Array[Node]

	if (aliveLives.is_empty()):
		return

	var _life: = aliveLives.back() as Node
	_life.set_meta("status", STATUS_DEAD)
	_life.texture = load(deathTexture) as Texture2D

	life_removed.emit()

	if (aliveLives.size() <= 1):
		died.emit()
