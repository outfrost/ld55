class_name Minion
extends Node3D

@export var damage: = 2
@export var hp: = 4
# lower number means higher priority, means goes first
@export var initiative_order: = 2
# multiply every int between 1 and speed (inclusive) by move directions to get all legal moves
@export var speed: = 2

var element: = Element.None

var move_directions: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
]

var attack_reach: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
]
