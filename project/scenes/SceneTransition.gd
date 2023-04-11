extends Node
class_name SceneTransition

signal transitioned_in
signal transitioned_out

enum Direction { LEFT = 0, RIGHT = 1, UP = 2, DOWN = 3 }

export(NodePath) var scene_node: NodePath

onready var _main = get_node("/root/Main")
onready var _scene: Node = get_node(scene_node)
onready var window_width: float = ProjectSettings.get_setting("display/window/size/width")
onready var window_height: float = ProjectSettings.get_setting("display/window/size/height")

func transition_out(duration: float) -> void:
	if _scene is Control:
		_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emit_signal("transitioned_out")

func transition_in(duration: float) -> void:
	emit_signal("transitioned_in")

func _fly_out(tween: SceneTreeTween, direction: int, duration: float) -> void:
	var property_name: String
	if _scene is Control:
		property_name = "rect_position"
	elif _scene is Node2D:
		property_name = "position"
	else:
		print("Cannot transition a scene that is not either a Control or Node2D.")
		return
	if direction == Direction.LEFT:
		tween.tween_property(_scene, property_name, Vector2(-window_width, 0), duration)
	elif direction == Direction.RIGHT:
		tween.tween_property(_scene, property_name, Vector2(window_width, 0), duration)
	elif direction == Direction.UP:
		tween.tween_property(_scene, property_name, Vector2(0, -window_height), duration)
	elif direction == Direction.DOWN:
		tween.tween_property(_scene, property_name, Vector2(0, window_height), duration)

func _fly_in(tween: SceneTreeTween, direction: int, duration: float) -> void:
	var property_name: String
	if _scene is Control:
		property_name = "rect_position"
	elif _scene is Node2D:
		property_name = "position"
	else:
		print("Cannot transition a scene that is not either a Control or Node2D.")
		return
	if direction == Direction.LEFT:
		_scene.get(property_name).x = window_width
	elif direction == Direction.RIGHT:
		_scene.get(property_name).x = -window_width
	elif direction == Direction.UP:
		_scene.get(property_name).y = window_height
	elif direction == Direction.DOWN:
		_scene.get(property_name).y = -window_height
	tween.tween_property(_scene, property_name, Vector2(0, 0), duration)

func _fade_out(tween: SceneTreeTween, duration: float) -> void:
	tween.tween_property(_scene, "modulate", Color(1, 1, 1, 0.0), duration)

func _fade_in(tween: SceneTreeTween, duration: float) -> void:
	_scene.modulate.a = 0
	tween.tween_property(_scene, "modulate", Color(1, 1, 1, 1.0), duration)

func _wipe(tween: SceneTreeTween, direction: int, duration: float) -> void:
	pass
