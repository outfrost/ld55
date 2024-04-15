extends Node3D
# This script should generate a bunch of cubes to be used as collisions for the tilemap when raycasting the mouse
# Ideally, this script is sepparate from the actual board manager, this being just a generator

@onready var tile : PackedScene = load("res://grid/TileSingle.tscn")
@onready var tile_dark : PackedScene = load("res://grid/TileSingleDark.tscn")

@export var height : int
@export var width : int
@export var grid_size : float = 1.5 # this is the size of a tile

# materials storage
var mat_normal : Material = load("res://grid/Materials/mat_tile.tres")
var mat_selected : Material = load("res://grid/Materials/mat_tile_selected.tres")
var mat_attack : Material = load("res://grid/Materials/mat_tile_attackable.tres")
var mat_transparent : Material = load("res://grid/Materials/mat_tile_transparent.tres")

# internal storage
var tiles_list = []
var tiles_occupied_rune = []
var tiles_occupied_minions = []
var selected_tile := - Vector2i.ONE
var freeze_overlay : bool
var card_selected : bool
var selected_card_data : CardData

func _ready():

	# Generate the board and initialise the matrices
	for i in range(width):
		tiles_list.append([])
		tiles_occupied_rune.append([])
		tiles_occupied_minions.append([])
		for j in range(height):
			var curTile : Node3D # make the pattern
			if (i + j) % 2 :
				curTile = tile.instantiate()
			else :
				curTile = tile_dark.instantiate()

			add_child(curTile)
			var rotation = randi_range(0,3)
			curTile.rotation = Vector3(0, rotation * TAU/4,0)
			curTile.position = Vector3( (i - float(width-1) / 2) * grid_size , 0 , -1 * (j - float(height-1) / 2 ) * grid_size )
			tiles_list[i].append(curTile)
			tiles_occupied_rune[i].append(null)
			tiles_occupied_minions[i].append(null)

			(curTile.get_node(^"Area3D") as Area3D).mouse_entered.connect(func(): TileHovered(i,j))
			(curTile.get_node(^"Area3D") as Area3D).input_event.connect(func(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int): TileClicked(i,j,event))
			(curTile.get_node(^"Area3D") as Area3D).mouse_exited.connect(func(): TileUnhovered(i,j))

			# connect to the hand
			get_node("../Camera3D/Hand").card_selected.connect(func(card_data: CardData): SelectedCard(card_data))
			get_node("../Camera3D/Hand").card_unselected.connect(func(): UnselectedCard())

func SelectedCard(card_data: CardData):
	card_selected = true
	selected_card_data = card_data
	ShowPlaceable()

func UnselectedCard():
	card_selected = false
	selected_card_data = null
	ClearBoard()

func TileHovered(x , y):
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_selected)

func TileUnhovered(x , y):
	ClearSelf(x,y)
	if card_selected and y < 2:
		if selected_card_data.minion and tiles_occupied_minions[x][y] == null :
			((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_normal)
		elif !selected_card_data.minion and tiles_occupied_rune[x][y] == null :
			((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_normal)
		#((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_normal)
	pass

func TileClicked(x , y, event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.button_mask == 1:
			if card_selected and y < 2 :
				PlaceOnTile(x,y)
			print("clicked left mouse on ", x, " ", y)
	pass

func ClearBoard() -> void: # resets the entire board MARKERS
	for i in range(width):
		for j in range(height):
			((tiles_list[i][j] as Node3D).get_node(^"Meshes/MeshAttack") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
			((tiles_list[i][j] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,null)
			((tiles_list[i][j] as Node3D).get_node(^"Meshes/MeshMove") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
	pass

func ClearSelf(x,y) -> void:
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/MeshAttack") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
	((tiles_list[x][y] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_transparent)
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

func ShowPlaceable():
	card_selected = true
	for i in range(width):
		for j in range(2):
			if selected_card_data.minion :
				if tiles_occupied_minions[i][j] == null :
					((tiles_list[i][j] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_normal)
			elif !selected_card_data.minion :
				if tiles_occupied_rune[i][j] == null :
					((tiles_list[i][j] as Node3D).get_node(^"Meshes/BaseSelector") as MeshInstance3D).set_surface_override_material(0,mat_normal)
	pass

func PlaceOnTile(x,y): #put data from card, on x y; returns true if it worked
	print("entered tile placing")
	if CheckSpawn(x,y):
		var spawnable = selected_card_data.spawn.instantiate()
		spawnable.position = Vector3( (x - float(width-1) / 2) * grid_size , 1 , -1 * (y - float(height-1) / 2 ) * grid_size )
		add_child(spawnable)
		if !selected_card_data.minion :
			tiles_occupied_rune[x][y] = spawnable
		else : # this is a minion
			tiles_occupied_minions[x][y] = spawnable
			# NOW WE NEED TO TURN THEM INTO AN ACTUAL THINKING BEING

		#
		#
		# MAKE THE CARD GO DOWN FROM THE HAND SCRIPT, THE CARD IS USED AND PLACED NOW
		#
		#
		ClearBoard()
		selected_card_data = null
		card_selected = false
	else :
		print("That tile is invalid, please pick another")


func CheckSpawn(x,y) -> bool: # check if you can spawn on that tile
	if selected_card_data.minion: # we're placing a minion
		if tiles_occupied_minions[x][y] != null :
			return false
		return true
	else : # we're trying to place a rune
		if tiles_occupied_rune[x][y] == null :
			return true
		return false

func PossibleMoves(): #returns vector 2 array of places to move
	pass

func PossibleAttacks(): #returns vector 2 array of places to attack
	pass

func MovePawn(): #from selected to location x/y
	pass

func _unhandled_input(event): #if we have right click, remove selection
	pass
