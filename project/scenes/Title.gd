extends Control

onready var _main = $"/root/Main"

const TEST_MATCH_SCENE = preload("res://scenes/Match.tscn")
const GAME_SETUP_SCENE = preload("res://scenes/GameSetup.tscn")
const TRAINING_SCENE = preload("res://scenes/Training.tscn")
const CREDITS_SCENE = preload("res://scenes/Credits.tscn")

var _selection := 0

onready var initial_selection := $Options/Play as Button

func _ready():
	initial_selection.grab_focus()

func _test() -> void:
	var scene = TEST_MATCH_SCENE.instance()
	_main.change_scene(scene)

func _play() -> void:
	var scene = GAME_SETUP_SCENE.instance()
	_main.change_scene(scene)

func _training() -> void:
	var scene = TRAINING_SCENE.instance()
	_main.change_scene(scene)

func _settings() -> void:
	pass

func _credits() -> void:
	var scene = CREDITS_SCENE.instance()
	_main.change_scene(scene)

func _quit() -> void:
	get_tree().quit(0)

# TODO: Extend the SceneTransition Script to overwrite the transition_out
