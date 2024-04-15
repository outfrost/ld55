class_name CardData
extends Resource

@export var spawn: PackedScene
@export var sprite: Texture2D
@export var text: String
@export_enum("None:Element.None", "Fire:Element.Fire", "Wind:Element.Wind", "Earth:Element.Earth") var element: int
