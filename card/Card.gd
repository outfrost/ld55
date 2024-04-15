extends Node3D

const HOVER_OFFSET_POS: = Vector3(0.0, 0.1, 0.01)
const HOVER_OFFSET_SCALE: = Vector3(1.3, 1.3, 1.3)

@onready var area: Area3D = $Area3D
@onready var visual: Node3D = $Visual

var visual_target_pos: = Vector3.ZERO
var visual_target_scale: = Vector3.ONE

func _ready() -> void:
	#area.input_ray_pickable = false
	area.mouse_entered.connect(hover)
	area.mouse_exited.connect(unhover)

func _process(delta: float) -> void:
	visual.position = visual.position.lerp(visual_target_pos, 0.1)
	visual.scale = visual.scale.lerp(visual_target_scale, 0.1)

#func activate() -> void:
	#area.input_ray_pickable = true

func hover() -> void:
	visual_target_pos = HOVER_OFFSET_POS
	visual_target_scale = HOVER_OFFSET_SCALE

func unhover() -> void:
	visual_target_pos = Vector3.ZERO
	visual_target_scale = Vector3.ONE
