extends Node

class DebugTracker:
	var node: Node
	var color: Color
	var props: Array[NodePath] = []
	var msgs: Array[String] = []
	var physics_msgs: Array[String] = []

	func _init(node: Node) -> void:
		self.node = node
		var h : = hash(node.get_path())
		self.color = Color.from_hsv((h & 0xff) / 256.0, 0.3 + ((h & 0xff00 >> 8) / 1200.0), 1.0, 1.0)

class DebugTrackerProxy extends RefCounted:
	var _tracker: DebugTracker
	var _visible_in_release: bool = false

	func _init(tracker: DebugTracker, visible_in_release: bool) -> void:
		_tracker = tracker
		_visible_in_release = visible_in_release

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PREDELETE:
			DebugOverlay._drop_tracker(_tracker)

	func trace(property: NodePath) -> DebugTrackerProxy:
		if DebugOverlay._release_mode && !_visible_in_release:
			return self
		if property.is_empty():
			push_error("missing property path")
			return self
		_tracker.props.append(property.get_as_property_path())
		return self

	func display(v: Variant) -> DebugTrackerProxy:
		if DebugOverlay._release_mode && !_visible_in_release:
			return self

		var msg: String
		if DebugOverlay.show_calling_function:
			var stack_frame = get_stack()[1]
			msg = "%s:%d :: %s" % [
				stack_frame.function,
				stack_frame.line,
				DebugOverlay._str(v),
			]
		else:
			msg = "%s" % DebugOverlay._str(v)

		if Engine.is_in_physics_frame():
			_tracker.physics_msgs.append(msg)
		else:
			_tracker.msgs.append(msg)

		return self

var show_calling_function: bool = true

@onready var _label: RichTextLabel = $DebugLabel
@onready var _release_mode: bool = !OS.has_feature("debug")

var _buffer: String = ""
var _trackers: Array[DebugTracker] = []

func _ready():
	_label.text = ""
	#print(_str(Rect2(10.0, 20.0, 100.0, 200.0)))
	#print(_str(Rect2i(8, 16, 128, 256)))
	#print(_str(Transform2D.IDENTITY))
	#print(_str(Transform3D.IDENTITY))
	#print(_str(Plane.PLANE_XZ))
	#print(_str(Quaternion.from_euler(Vector3(0.49, TAU * 0.52, TAU * 0.71))))
	#print(_str(AABB(Vector3(1.0, 2.0, 3.0), Vector3(5.0, 5.0, 6.0))))
	#print(_str(Basis.IDENTITY))
	#print(_str(Projection.IDENTITY))
	#print(_str(Color.INDIGO))

func _process(_delta):
	_process_trackers()
	_label.text = _buffer
	_buffer = ""

func _physics_process(delta: float) -> void:
	_clear_tracker_physics_msgs()

func tracker(node: Node) -> DebugTrackerProxy:
	var tracker = DebugTracker.new(node)
	if !_release_mode:
		_trackers.append(tracker)
	return DebugTrackerProxy.new(tracker, false)

func public_tracker(node: Node) -> DebugTrackerProxy:
	var tracker = DebugTracker.new(node)
	_trackers.append(tracker)
	return DebugTrackerProxy.new(tracker, true)

func display(v: Variant) -> void:
	if _release_mode:
		return
	_buffer += _str(v) + "\n"

func display_public(v: Variant) -> void:
	_buffer += _str(v) + "\n"

func _process_trackers() -> void:
	for tracker in _trackers:
		_buffer += "[color=#%s][%s]\n" % [tracker.color.to_html(), tracker.node.name]
		var one: = false
		for prop in tracker.props:
			if one:
				_buffer += ", "
			else:
				_buffer += "    "
			var prop_name: StringName = prop.get_concatenated_subnames()
			_buffer += "%s: %s" % [ prop_name, _str(tracker.node.get(prop_name)) ]
			one = true
		if one:
			_buffer += "\n"
		for msg in tracker.msgs:
			_buffer += "    %s\n" % msg
		tracker.msgs.clear()
		for msg in tracker.physics_msgs:
			_buffer += "    %s\n" % msg
		_buffer += "[/color]"

func _clear_tracker_physics_msgs() -> void:
	for tracker in _trackers:
		tracker.physics_msgs.clear()

func _drop_tracker(tracker: DebugTracker) -> void:
	_trackers.erase(tracker)

func _str(v: Variant) -> String:
	match typeof(v):
		TYPE_BOOL:
			return " true" if v else "false"
		TYPE_INT:
			return "%3d" % v
		TYPE_FLOAT:
			return "%7.4f" % v
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
			return "%7.4v" % v
		TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I:
			return "%3.v" % v
		TYPE_RECT2, TYPE_AABB:
			return "(pos: %7.4v, size: %7.4v)" % [v.position, v.size]
		TYPE_RECT2I:
			return "(pos: %3.v, size: %3.v)" % [v.position, v.size]
		TYPE_TRANSFORM2D:
			return "(pos: %7.4v, rot: %7.2f°, scl: %7.4v, skew: %7.2f°)" % [
				v.origin,
				rad_to_deg(v.get_rotation()),
				v.get_scale(),
				rad_to_deg(v.get_skew()),
			]
		TYPE_PLANE:
			return "(nrm: %7.4v, dist: %7.4f)" % [v.normal, v.d]
		TYPE_QUATERNION:
			return "(%7.4f, %7.4f, %7.4f, %7.4f)" % [v.x, v.y, v.z, v.w]
		TYPE_BASIS:
			var euler: Vector3 = v.get_euler()
			return "(rot: (%7.2f°, %7.2f°, %7.2f°), scl: %7.4v)" % [
				rad_to_deg(euler.x),
				rad_to_deg(euler.y),
				rad_to_deg(euler.z),
				v.get_scale(),
			]
		TYPE_TRANSFORM3D:
			var euler: Vector3 = v.basis.get_euler()
			return "(pos: %7.4v, rot: (%7.2f°, %7.2f°, %7.2f°), scl: %7.4v)" % [
				v.origin,
				rad_to_deg(euler.x),
				rad_to_deg(euler.y),
				rad_to_deg(euler.z),
				v.basis.get_scale(),
			]
		TYPE_PROJECTION:
			return "(c0: %7.4v, c1: %7.4v, c2: %7.4v, c3: %7.4v)" % [v.x, v.y, v.z, v.w]
		TYPE_COLOR:
			var hex: String = v.to_html()
			return "[color=#%s]■[/color] (r: %6.4f, g: %6.4f, b: %6.4f, a: %6.4f, hex: #%s)" % [
				hex,
				v.r,
				v.g,
				v.b,
				v.a,
				hex
			]
		#TYPE_DICTIONARY:
		#TYPE_ARRAY:
		_:
			return str(v)
