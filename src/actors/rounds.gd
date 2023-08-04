@tool # so that we see the rounds in the editor

extends HFlowContainer

signal all_completed(numTotal:int, numPassed: int, numFailed: int)
signal round_completed(passed: bool)


@export var numRounds:int = 10 :
	set(value):
		numRounds = value
		reset()

@export_file() var roundTexture:String
@export_file() var roundCurrentTexture:String
@export_file() var roundPassTexture:String

var currentRound:int = 1

const STATUS_INCOMPLETE:int = 0
const STATUS_PASSED:int = 1
const STATUS_FAILED:int = 2

func _enter_tree() -> void:
	reset()

func _all_completed() -> void:
	print("ALL ROUNDS COMPLETED") # TEMP DEV: remove this
	all_completed.emit(
		get_child_count(),
		get_children().filter(func (child:Node) -> bool: return child.get_meta("status") == STATUS_PASSED).size(),
		get_children().filter(func (child:Node) -> bool: return child.get_meta("status") == STATUS_FAILED).size(),
	)

func reset() -> void:
	for child in get_children():
		child.queue_free()

	for numRound in numRounds:
		var _round: = TextureRect.new()
		_round.set_meta("status", STATUS_INCOMPLETE)
		_round.texture = load(roundCurrentTexture if numRound == 0 else roundTexture) as Texture2D
		add_child(_round)

func next_round(passed:bool) -> void:
	var incompleteRounds:Array[Node] = get_children().filter(
		func (child:Node) -> bool: return child.get_meta("status") == STATUS_INCOMPLETE
	) as Array[Node]

	if (incompleteRounds.is_empty()):
		return

	var _round: = incompleteRounds[0]

	if (passed):
		_round.set_meta("status", STATUS_PASSED)
		_round.texture = load(roundPassTexture) as Texture2D
	else:
		_round.set_meta("status", STATUS_FAILED)
		_round.texture = load(roundTexture) as Texture2D

	round_completed.emit(passed)

	if (incompleteRounds.size() > 1):
		incompleteRounds[1].texture = load(roundCurrentTexture) as Texture2D
	else:
		_all_completed()

func pass_round() -> void:
	next_round(true)

func fail_round() -> void:
	next_round(false)

# TEMP DEV: just testing the rounds counter

func _on_back_button_pressed() -> void:
	pass_round()

func _on_texture_button_pressed() -> void:
	fail_round()
