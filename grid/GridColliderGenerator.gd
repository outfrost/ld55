extends Node3D
# This script should generate a bunch of cubes to be used as collisions for the tilemap when raycasting the mouse
# Ideally, this script is sepparate from the actual board manager, this being just a generator

@onready var tile : PackedScene = load("res://grid/TileSingle.tscn")
@onready var tile_dark : PackedScene = load("res://grid/TileSingleDark.tscn")

@export var height : int
@export var width : int
@export var grid_size : float = 1.5 # this is the size of a tile

# materials storage
var mat_selected : Material = load("res://grid/Materials/mat_tile_selected.tres")
var mat_attack : Material = load("res://grid/Materials/mat_tile_attackable.tres")
var mat_transparent : Material = load("res://grid/Materials/mat_tile_transparent.tres")

# internal storage
var tiles_list = []
var tiles_occupied = []
var selected_tile := - Vector2i.ONE
var freeze_overlay : bool

func _ready():

	# Generate the board and initialise the matrices
	for i in range(width):
		tiles_list.append([])
		tiles_occupied.append([])
		for j in range(height):
			var curTile : Node3D # make the pattern
			if (i + j) % 2 :
				curTile = tile.instantiate()
			else :
				curTile = tile_dark.instantiate()

			add_child(curTile)
			curTile.position = Vector3( (i - float(width-1) / 2) * grid_size , 0 , -1 * (j - float(height-1) / 2 ) * grid_size )
			tiles_list[i].append(curTile)
			tiles_occupied[i].append(null)

			(curTile.get_node(^"Area3D") as Area3D).mouse_entered.connect(func(): TileHovered(i,j))
			(curTile.get_node(^"Area3D") as Area3D).input_event.connect(func(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int): TileClicked(i,j,event))
			(curTile.get_node(^"Area3D") as Area3D).mouse_exited.connect(func(): TileUnhovered(i,j))


func TileHovered(x , y):
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_selected)
	#clicked on tile to select it

	#see where tile can attack
	#((tiles_list[x][y] as Node3D).get_node(^"Meshes/MeshAttack") as MeshInstance3D).set_surface_override_material(0,mat_attack)

	#see where tile can move
	#((tiles_list[x][y] as Node3D).get_node(^"Meshes/MeshMove") as MeshInstance3D).set_surface_override_material(0,mat_selected)

	#print("tile hovered xy: " ,x ,y)

func TileUnhovered(x , y):
	if !(selected_tile.x == x and selected_tile.y == y):
		ClearSelf(x,y)
	pass

func TileClicked(x , y, event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.button_mask == 1:
			print("clicked left mouse on ", x, " ", y)
			ClearSelf(selected_tile.x,selected_tile.y)
			selected_tile.x = x
			selected_tile.y = y

	#if event is click, set as active, stop hover, show possiblemoves
	#if event is right click ON ANY TILE, reset board

	pass

func ClearBoard() -> void: # resets the entire board
	for i in range(width):
		for j in range(height):
			((tiles_list[i][j] as Node3D).get_node(^"Meshes/MeshAttack") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
			((tiles_list[i][j] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,null)
			((tiles_list[i][j] as Node3D).get_node(^"Meshes/MeshMove") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
	pass

func ClearSelf(x,y) -> void:
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/MeshAttack") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,null)
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/MeshMove") as MeshInstance3D).set_surface_override_material(0,mat_transparent)

func IsOnBoard(a : Array) -> bool : # takes a 2-pair, returns true if its on the board
	if a[0] < 0 or a[0] >= width:
		return false
	if a[1] < 0 or a[1] >= height:
		return false
	return true

###
### This area might need a change to allow attacking the base/king
###

func FitOnBoard(a : Array) -> Array: # takes an array of 2-pairs, returns an array only of positions on the board
	var b : Array
	for i in a.size():
		if IsOnBoard(a[i]):
			b.append(a[i])
	return b

func PossibleMoves(): #returns vector 2 array of places to move
	pass

func PossibleAttacks(): #returns vector 2 array of places to attack
	pass

func PlayOnTile(): #put data from card, on x y; 3 variables
	pass

func CheckSpawn():
	pass

func MovePawn(): #from selected to location x/y
	pass

func _unhandled_input(event): #if we have right click, remove selection
	pass
