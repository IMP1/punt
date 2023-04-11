extends SceneTransition

func transition_out(duration: float) -> void:
	if _scene is Control:
		_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween := _scene.get_tree().create_tween()
	_fly_out(tween, Direction.LEFT, 1.0)
	yield(tween, "finished")
	emit_signal("transitioned_out")
