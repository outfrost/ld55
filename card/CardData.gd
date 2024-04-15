class_name CardData
extends Resource

@export var spawn: PackedScene
@export var minion: bool
@export var sprite: Texture2D
@export var text: String
@export var description: String
@export_enum("None", "Fire", "Wind", "Earth") var element: int
