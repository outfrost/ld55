class_name Card
extends Node3D

signal selected

const HOVER_OFFSET_POS: = Vector3(0.0, 0.1, 0.01)
const HOVER_OFFSET_SCALE: = Vector3(1.3, 1.3, 1.3)

@onready var area: Area3D = $Area3D
@onready var visual: Node3D = $Visual

var visual_target_pos: = Vector3.ZERO
var visual_target_scale: = Vector3.ONE
var keep_scale: bool = false

func _ready() -> void:
	area.mouse_entered.connect(hover)
	area.mouse_exited.connect(unhover)
	area.input_event.connect(input_event)

func _process(delta: float) -> void:
	visual.position = visual.position.lerp(visual_target_pos, 0.1)
	visual.scale = visual.scale.lerp(visual_target_scale, 0.1)

func set_pickable(active: bool) -> void:
	keep_scale = !active
	if active:
		visual_target_scale = Vector3.ONE
	area.input_ray_pickable = active

func hover() -> void:
	visual_target_pos = HOVER_OFFSET_POS
	if !keep_scale:
		visual_target_scale = HOVER_OFFSET_SCALE

func unhover() -> void:
	visual_target_pos = Vector3.ZERO
	if !keep_scale:
		visual_target_scale = Vector3.ONE

func input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var ev: = event as InputEventMouseButton
	if !ev:
		return
	if ev.button_index == MOUSE_BUTTON_LEFT && ev.pressed:
		selected.emit()
