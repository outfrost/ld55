extends Control

const GAME: PackedScene = preload("res://game/Game.tscn")

func _ready() -> void:
	if OS.has_feature("debug") && FileAccess.file_exists("res://debug.gd"):
		var debug_script: GDScript = load("res://debug.gd")
		if debug_script:
			if (debug_script.get_script_constant_map() as Dictionary).get("SKIP_SPLASH", false):
				get_tree().call_deferred("change_scene_to_packed", GAME)

	get_tree().create_timer(2.0).timeout.connect(func():
		$AudioStreamPlayer.play()
		$Godot.show()
		get_tree().create_timer(3.0).timeout.connect(func():
			get_tree().change_scene_to_packed(GAME)
		)
	)
