extends Node3D
# This script should generate a bunch of cubes to be used as collisions for the tilemap when raycasting the mouse
# Ideally, this script is sepparate from the actual board manager, this being just a generator

@onready var tile : PackedScene = load("res://grid/TileSingle.tscn")
@export var height : int
@export var width : int


func _ready():

	for i in range(height):
		for j in range(width):
			var curTile : Node3D = tile.instantiate()
			add_child(curTile)
			curTile.position = Vector3(0, 1,0)
			print(curTile.transform)

