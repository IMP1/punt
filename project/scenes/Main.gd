extends Node

onready var _scene_container: Node = $CurrentScene as Node
onready var _current_scene: Node = $CurrentScene.get_child(0) as Node

const DEFAULT_DURATION = 0.2

onready var _tween: Tween = $Tween as Tween

func change_scene(next_scene: Node, duration:float=DEFAULT_DURATION) -> void:
	_scene_container.add_child(next_scene)
	if _current_scene != null:
		var transition_out: SceneTransition = _current_scene.get_node_or_null("SceneTransition")
		if transition_out != null:
			transition_out.connect("transitioned_out", self, "_scene_finished", [_current_scene])
			transition_out.transition_out(duration)
		else:
			_current_scene.queue_free()
	_current_scene = next_scene
	var transition_in: SceneTransition = _current_scene.get_node_or_null("SceneTransition")
	if transition_in != null:
		transition_in.transition_in(duration)
		yield(transition_in, "transitioned_in")
	print("New scene transitioned in")
	if _current_scene.has_method("start"):
		_current_scene.start()

func _scene_finished(scene: Node):
	scene.queue_free()
