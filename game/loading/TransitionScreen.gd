class_name TransitionScreen
extends Control

signal animation_finished()

enum AnimationState {
	IDLE,
	FADING_IN,
	FADING_OUT,
}

@export var fade_in_duration: float = 0.5
@export var fade_in_node: NodePath = ^"."
@export var fade_out_duration: float = 0.5
@export var fade_out_node: NodePath = ^"."

@onready var fade_in_control: Control = get_node(fade_in_node)
@onready var fade_out_control: Control = get_node(fade_out_node)

var anim_state: AnimationState = AnimationState.IDLE
var anim_time: float = 0.0

func _process(delta: float) -> void:
	anim_time += delta
	match anim_state:
		AnimationState.IDLE:
			pass
		AnimationState.FADING_IN:
			fade_in_control.modulate.a = clamp(inverse_lerp(0.0, fade_in_duration, anim_time), 0.0, 1.0)
			if anim_time >= fade_in_duration:
				anim_state = AnimationState.IDLE
				animation_finished.emit()
		AnimationState.FADING_OUT:
			fade_out_control.modulate.a = clamp(inverse_lerp(fade_out_duration, 0.0, anim_time), 0.0, 1.0)
			if anim_time >= fade_out_duration:
				hide()
				anim_state = AnimationState.IDLE
				animation_finished.emit()

func fade_in() -> void:
	fade_in_control.modulate.a = 0.0
	show()
	anim_time = 0.0
	anim_state = AnimationState.FADING_IN

func fade_out() -> void:
	anim_time = 0.0
	anim_state = AnimationState.FADING_OUT
