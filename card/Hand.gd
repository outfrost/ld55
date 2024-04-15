extends Node3D

const HAND_SIZE: = 7
const CARD_SCN: = preload("res://card/Card.tscn")

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

var card_xforms = {}

func _ready() -> void:
	draw()

func _process(delta: float) -> void:
	for card in card_xforms:
		card.position = card.position.lerp(card_xforms[card].origin, 0.1)
		card.basis = card.basis.slerp(card_xforms[card].basis, 0.1)

func draw() -> void:
	var num_draw: = HAND_SIZE - card_xforms.size()
	for i in range(num_draw):
		var card: = CARD_SCN.instantiate()
		card.transform = spawn_xform
		add_child(card)
		card_xforms[card] = card.transform
	align()

func align() -> void:
	var first_idx: = 3 - (card_xforms.size() / 2)
	var cards: = card_xforms.keys()
	for i in range(card_xforms.size()):
		card_xforms[cards[i]] = xforms[i + first_idx]
