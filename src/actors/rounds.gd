@tool # so that we see the rounds in the editor

extends HFlowContainer

signal all_completed(num_total:int, num_passed: int, num_failed: int)
signal round_completed(passed: bool)


@export var num_rounds:int = 10 :
	set(value):
		num_rounds = value
		reset()

@export_file() var round_texture:String
@export_file() var round_current_texture:String
@export_file() var round_pass_texture:String

## returns the index of the current round (zero-indexed)
var current_round:int :
	get:
		var incomplete_rounds:Array[Node] = get_children().filter(
			func (child:Node) -> bool: return child.get_meta("status") == STATUS_INCOMPLETE
		) as Array[Node]

		if incomplete_rounds.is_empty():
			return -1

		return get_children().find(incomplete_rounds.front())

const STATUS_INCOMPLETE:int = 0
const STATUS_PASSED:int = 1
const STATUS_FAILED:int = 2

func _enter_tree() -> void:
	reset()

func _all_completed() -> void:
	all_completed.emit(
		get_child_count(),
		get_children().filter(func (child:Node) -> bool: return child.get_meta("status") == STATUS_PASSED).size(),
		get_children().filter(func (child:Node) -> bool: return child.get_meta("status") == STATUS_FAILED).size(),
	)

func reset() -> void:
	if !is_inside_tree():
		return

	for child in get_children():
		child.queue_free()

	for num_round in num_rounds:
		var _round: = TextureRect.new()
		_round.set_meta("status", STATUS_INCOMPLETE)
		_round.texture = load(round_current_texture if num_round == 0 else round_texture) as Texture2D
		add_child(_round)

func next_round(passed:bool) -> void:
	var incomplete_rounds:Array[Node] = get_children().filter(
		func (child:Node) -> bool: return child.get_meta("status") == STATUS_INCOMPLETE
	) as Array[Node]

	if incomplete_rounds.is_empty():
		return

	var _round: = incomplete_rounds.front() as TextureRect

	if passed:
		_round.set_meta("status", STATUS_PASSED)
		_round.texture = load(round_pass_texture) as Texture2D
	else:
		_round.set_meta("status", STATUS_FAILED)
		_round.texture = load(round_texture) as Texture2D

	round_completed.emit(passed)

	if incomplete_rounds.size() > 1:
		incomplete_rounds[1].texture = load(round_current_texture) as Texture2D
	else:
		_all_completed()

func pass_round() -> void:
	next_round(true)

func fail_round() -> void:
	next_round(false)
