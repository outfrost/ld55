extends Node3D

signal card_selected(card_data: CardData)
signal card_unselected

const HAND_SIZE: = 7
const CARD_SCN: = preload("res://card/Card.tscn")

class HandCard:
	var node: Card
	var target_xform: Transform3D
	var draw_finished: bool = false

	func _init(node: Card, target_xform: Transform3D) -> void:
		self.node = node
		self.target_xform = target_xform

@export var deck: Deck

@onready var xforms: Array[Transform3D] = [
	$CardPos0.transform,
	$CardPos1.transform,
	$CardPos2.transform,
	$CardPos3.transform,
	$CardPos4.transform,
	$CardPos5.transform,
	$CardPos6.transform,
]

@onready var spawn_xform: Transform3D = $SpawnPos.transform
@onready var hold_xform: Transform3D = $HoldPos.transform

var cards: Array[HandCard] = []
var selected: Card = null

var debug: = DebugOverlay.tracker(self)

func _ready() -> void:
	($Control as Control).gui_input.connect(gui_input)
	await get_tree().create_timer(1.0).timeout
	draw()

func _process(delta: float) -> void:
	#DebugOverlay.display_public("fps %d" % Performance.get_monitor(Performance.TIME_FPS))
	for i in range(cards.size()):
		var card = cards[i]
		var dist: float = (card.target_xform.origin - card.node.position).length()

		if !card.draw_finished && dist < 0.01:
			card.draw_finished = true

		var lerp_rate: float
		if card.draw_finished:
			lerp_rate = clamp((5.0 / (0.2 + sqrt(dist))) * delta, 0.0, 0.25)
		else:
			lerp_rate = clamp(((5.0 / (0.2 + sqrt(dist))) - 1.5 * sqrt(i)) * delta, 0.0, 0.25)

		card.node.position = card.node.position.lerp(card.target_xform.origin, lerp_rate)
		card.node.basis = card.node.basis.slerp(card.target_xform.basis, lerp_rate).orthonormalized()

func gui_input(event: InputEvent) -> void:
	var ev: = event as InputEventMouseButton
	if !ev:
		return
	if ev.button_index == MOUSE_BUTTON_RIGHT && ev.pressed:
		unselect_card()

func draw() -> void:
	var num_draw: = HAND_SIZE - cards.size()
	for i in range(num_draw):
		var card: = CARD_SCN.instantiate()

		card.data = deck.pool.pick_random()

		card.transform = spawn_xform
		add_child(card)
		card.selected.connect(func(): on_card_selected(card))
		cards.append(HandCard.new(card, spawn_xform))
	align()

func align() -> void:
	var first_idx: = 3 - (cards.size() / 2)
	for i in range(cards.size()):
		cards[i].target_xform = xforms[i + first_idx]

func on_card_selected(card: Card) -> void:
	for c in cards:
		c.node.set_pickable(false)
		if c.node == card:
			c.target_xform = hold_xform
	selected = card
	card_selected.emit(selected.data)

func unselect_card() -> void:
	if !selected:
		return

	card_unselected.emit()
	selected = null
	for card in cards:
		card.node.set_pickable(true)
	align()

func use_selected_card() -> void:
	if !selected:
		return

	remove_child(selected)
	var idx: = 0
	for i in range(cards.size()):
		if cards[i].node == selected:
			idx = i
			break

	cards.remove_at(idx)
	selected.queue_free()
	unselect_card()
