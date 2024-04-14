extends Node3D

const HOVER_OFFSET_POS: = Vector3(0.0, 0.06, 0.06)

@onready var area: Area3D = $Area3D
@onready var visual: Node3D = $Visual

var visual_target_pos: = Vector3.ZERO

func _ready() -> void:
	area.mouse_entered.connect(hover)
	area.mouse_exited.connect(unhover)

func _process(delta: float) -> void:
	visual.position = visual.position.lerp(visual_target_pos, 0.1)

func hover() -> void:
	visual_target_pos = HOVER_OFFSET_POS

func unhover() -> void:
	visual_target_pos = Vector3.ZERO
