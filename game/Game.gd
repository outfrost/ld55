class_name Game
extends Node

@onready var main_menu: Control = $UI/MainMenu
@onready var transition_screen: TransitionScreen = $UI/TransitionScreen
@onready var menu_background: Node = $MenuBackground
#@onready var menu_background_content: Node = menu_background.get_child(0)

@onready var debug: = DebugOverlay.tracker(self)

var debug_hook: RefCounted

func _ready() -> void:
	if OS.has_feature("debug") && FileAccess.file_exists("res://debug.gd"):
		var debug_script: GDScript = load("res://debug.gd")
		if debug_script:
			debug_hook = debug_script.new(self)
			debug_hook.startup()

	main_menu.start_game.connect(on_start_game)

func _process(delta: float) -> void:
	DebugOverlay.display_public("fps %d" % Performance.get_monitor(Performance.TIME_FPS))

	if Input.is_action_just_pressed("menu"):
		back_to_menu()

func _physics_process(delta: float) -> void:
	pass

func on_start_game() -> void:
	main_menu.hide()
	#menu_background.remove_child(menu_background_content)
	Harbinger.prune()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func back_to_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	#menu_background.add_child(menu_background_content)
	main_menu.show()
