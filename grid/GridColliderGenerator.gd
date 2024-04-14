extends Node3D
# This script should generate a bunch of cubes to be used as collisions for the tilemap when raycasting the mouse
# Ideally, this script is sepparate from the actual board manager, this being just a generator

@onready var tile : PackedScene = load("res://grid/TileSingle.tscn")
@export var height : int
@export var width : int
@export var grid_size : float = 1.5 # this is the size of a tile
@export var mat_selected : Material

var tiles_list = []


func _ready():

	for i in range(width):
		tiles_list.append([])
		for j in range(height):
			var curTile : Node3D = tile.instantiate()
			add_child(curTile)
			curTile.position = Vector3( (i - float(width-1) / 2) * grid_size , 0 , -1 * (j - float(height-1) / 2 ) * grid_size )

			tiles_list[i].append(curTile)


			(curTile.get_node(^"Area3D") as Area3D).mouse_entered.connect(func(): TileHovered(i,j))
			(curTile.get_node(^"Area3D") as Area3D).mouse_exited.connect(func(): TileUnhovered(i,j))
			#store in table

func TileHovered(x , y):
	((tiles_list[x][y] as Node3D).get_node(^"MeshInstance3D") as MeshInstance3D).set_surface_override_material(0,mat_selected)
	print("tile hovered xy: " ,x ,y)

func TileUnhovered(x , y):
	((tiles_list[x][y] as Node3D).get_node(^"MeshInstance3D") as MeshInstance3D).set_surface_override_material(0,null)
	#print("tile unhovered xy: " ,x ,y)
	pass

func PlayOnTile(): #put data from card, on x y; 3 variables
	pass

func CheckSpawn():
	pass

func MovePawns():
	pass
