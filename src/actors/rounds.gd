@tool # so that we see the rounds in the editor

extends HFlowContainer

signal all_completed(num_total:int, num_passed: int, num_failed: int)
signal round_completed(passed: bool)


@export var num_rounds:int = 10 :
	set(value):
		num_rounds = value
		reset()

@export var round_texture:Texture2D
@export var round_current_texture:Texture2D
@export var round_pass_texture:Texture2D

## returns the index of the current round (zero-indexed)
var current_round:int :
	get:
		var incomplete_rounds:Array[Node] = get_children().filter(
			func (child:Node) -> bool: return child.get_meta("status") == STATUS_INCOMPLETE
		) as Array[Node]

		if incomplete_rounds.is_empty():
			return -1

		return get_children().find(incomplete_rounds.front())

var rounds_left:int :
	get:
		return num_rounds - current_round if current_round != -1 else 0

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
		_round.texture = round_current_texture if num_round == 0 else round_texture
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
		_round.texture = round_pass_texture
	else:
		_round.set_meta("status", STATUS_FAILED)
		_round.texture = round_texture

	round_completed.emit(passed)

	if incomplete_rounds.size() > 1:
		incomplete_rounds[1].texture = round_current_texture
	else:
		_all_completed()


func pass_round() -> void:
	next_round(true)


func fail_round() -> void:
	next_round(false)
