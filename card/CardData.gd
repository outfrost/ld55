class_name CardData
extends Resource

enum Spawn {
	Elemental,
	Kobold,
	Moth,
	AttackRune1,
	AttackRune2,
	TauntRune,
	HealRune,
	MoveBackRune,
	MoveDiagonalRune,
}

@export var spawn: Spawn
@export var sprite: Texture2D
@export var text: String
