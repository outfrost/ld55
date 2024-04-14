extends Node3D
# This script should generate a bunch of cubes to be used as collisions for the tilemap when raycasting the mouse
# Ideally, this script is sepparate from the actual board manager, this being just a generator

@onready var tile : PackedScene = load("res://grid/TileSingle.tscn")
@export var height : int
@export var width : int
@export var grid_size : float = 1.5 # this is the size of a tile

# how tf do i make a table


func _ready():

	for i in range(height):
		for j in range(width):
			var curTile : Node3D = tile.instantiate()
			add_child(curTile)
			curTile.position = Vector3( (j - float(width-1) / 2) * grid_size , 0 , (i - float(height-1) / 2 ) * grid_size )
			(curTile.get_node(^"Area3D") as Area3D).mouse_entered.connect(TileHovered)

func _physics_process(delta):

	pass



func TileHovered(x , y):
	print("tile hovered xy: " ,x ,y)
