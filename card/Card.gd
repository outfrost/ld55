class_name Card
extends Node3D

signal selected

const HOVER_OFFSET_POS: = Vector3(0.0, 0.1, 0.01)
const HOVER_OFFSET_SCALE: = Vector3(1.3, 1.3, 1.3)

@onready var area: Area3D = $Area3D
@onready var visual: Node3D = $Visual

var sprite_mat: StandardMaterial3D = null

var data: CardData:
	set(v):
		data = v
		if v:
			$Visual/Front/CardText.text = v.text
			$Visual/Front/CardDescription.text = v.description
			if !sprite_mat:
				$Visual/Front/Sprite.mesh = $Visual/Front/Sprite.mesh.duplicate(true)
				sprite_mat = $Visual/Front/Sprite.mesh.material
				sprite_mat.albedo_color = Color.WHITE
			sprite_mat.albedo_texture = v.sprite
			match v.element:
				1: # Fire
					sprite_mat.albedo_color = Color.from_hsv(355.0 / 360.0, 0.5, 1.0, 1.0)
				2: # Wind
					sprite_mat.albedo_color = Color.from_hsv(240.0 / 360.0, 0.5, 1.0, 1.0)
				3: # Earth
					sprite_mat.albedo_color = Color.from_hsv(150.0 / 360.0, 0.5, 1.0, 1.0)

var visual_target_pos: = Vector3.ZERO
var visual_target_scale: = Vector3.ONE
var keep_scale: bool = false

func _ready() -> void:
	area.mouse_entered.connect(hover)
	area.mouse_exited.connect(unhover)
	area.input_event.connect(input_event)

func _process(delta: float) -> void:
	visual.position = visual.position.lerp(visual_target_pos, 14.0 * delta)
	visual.scale = visual.scale.lerp(visual_target_scale, 14.0 * delta)

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
