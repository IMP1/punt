extends Control

onready var _main = $"/root/Main"

const TEST_MATCH_SCENE = preload("res://scenes/Match.tscn")
const CREDITS_SCENE = preload("res://scenes/Credits.tscn")

var _selection = 0

func _ready():
	_refresh_selection()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_selection += 1
		if _selection >= $Options.get_child_count():
			_selection = 0
	if event.is_action_pressed("ui_up"):
		_selection -= 1
		if _selection < 0:
			_selection = $Options.get_child_count() - 1
	_refresh_selection()
	if event.is_action_pressed("ui_accept"):
		var button: Button = $Options.get_child(_selection)
		button.emit_signal("pressed")

func _refresh_selection() -> void:
	var button: Button = $Options.get_child(_selection)
	button.grab_focus()

func _play() -> void:
	var scene = TEST_MATCH_SCENE.instance()
	_main.change_scene(scene)

func _training() -> void:
	pass

func _settings() -> void:
	pass

func _credits() -> void:
	var scene = CREDITS_SCENE.instance()
	_main.change_scene(scene)

func _quit() -> void:
	get_tree().quit(0)

# TODO: Extend the SceneTransition Script to overwrite the transition_out
