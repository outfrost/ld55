class_name Minion
extends Node3D

#const MAT_PLAIN: Material = preload("res://pawn/mat_creatures_wood.tres")
const MAT_FIRE: Material = preload("res://pawn/mat_creatures_fire.tres")
const MAT_WIND: Material = preload("res://pawn/mat_creatures_wind.tres")
const MAT_EARTH: Material = preload("res://pawn/mat_creatures_earth.tres")

@export var damage: = 2
@export var hp: = 4
# lower number means higher priority, means goes first
@export var initiative_order: = 2
# multiply every int between 1 and speed (inclusive) by move directions to get all legal moves
@export var speed: = 2
@export var mesh_inst: MeshInstance3D

var element: = Element.None:
	set(v):
		element = v
		match v:
			Element.None:
				mesh_inst.set_surface_override_material(0, null)
			Element.Fire:
				mesh_inst.set_surface_override_material(0, MAT_FIRE)
			Element.Wind:
				mesh_inst.set_surface_override_material(0, MAT_WIND)
			Element.Earth:
				mesh_inst.set_surface_override_material(0, MAT_EARTH)

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

var taunt: = false
var heal_allies: = false

var enemy: = false

func _ready() -> void:
	assert(mesh_inst)
