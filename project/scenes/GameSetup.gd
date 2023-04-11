extends Control

const ARENA_FILEPATHS = ["res://data/arenas/", "user://arenas"]
const MATCH_SCENE = preload("res://scenes/Match.tscn")
const PLAYER_ICON = preload("res://gui/PlayerIcon.tscn")

enum GameMode { CLASSIC, VOLLIES, ONE_TOUCH }

const GAME_MODE_NAMES = {
	0: "Classic",
	1: "Vollies",
	2: "One-Touch",
}

export(Array, Color) var player_colours = [
	Color("905454"),
	Color("b28b39"),
	Color("714a8f"),
	Color("a45a78"),
	Color("3d965b"),
	Color("ffffff"),
]

var _all_arenas = []
var _game_mode: int = GameMode.CLASSIC
var _available_arenas = ["res://data/arenas/Lake.tscn"]
var _current_arena = load(_available_arenas[0])
var _current_settings: MatchSettings = preload("res://data/3_min_match.tres")
var _valid_teams: bool = false

onready var _main = $"/root/Main"
onready var _player_list: Control = $Teams/PlayerList
onready var _team_list: Control = $Teams/TeamList
onready var _initial_selection := $Options/GameMode/Button as Button

func _ready() -> void:
	_load_all_arenas()
	print(_all_arenas)
	InputManager.connect("gamepad_connected", self, "player_joined")
	for id in Input.get_connected_joypads():
		_player_joined(id)
	_setup_defaults()
	_refresh_team_list()
	_refresh_match_ending_settings()
	_initial_selection.grab_focus()

func _load_all_arenas() -> void:
	_all_arenas = []
	for path in ARENA_FILEPATHS:
		var dir := Directory.new()
		var result = dir.open(path)
		if result != OK:
			continue
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			if file.begins_with("."):
				continue
			_all_arenas.append(load(path + "/" + file))
		dir.list_dir_end()

func _setup_defaults() -> void:
	_current_settings.goals_to_lose = 1
	_current_settings.goals_to_win = 1

func _refresh_team_list() -> void:
	for child in _team_list.get_children():
		_team_list.remove_child(child)
	for i in _current_settings.team_count:
		var num := Label.new()
		_team_list.add_child(num)
		num.text = str(i + 1)
		num.align = Label.ALIGN_CENTER
		num.size_flags_horizontal += SIZE_EXPAND

func _refresh_game_mode() -> void:
	$Options/GameMode/Button.text = GAME_MODE_NAMES[_game_mode]
	_available_arenas = _get_available_arenas()
	_current_arena = _available_arenas[0]
	_refresh_arena()

func _refresh_arena() -> void:
	print(_current_arena)
	var state: SceneState = _current_arena.get_state()
	print(state)
	print(state.get_node_count())
	$Options/Arena/Button/Value.text = state.get_node_name(0)
	# TODO: Somehow save and get an icon / minimap for the map...
	$Options/Arena/Button/Icon.texture = null
	# TODO: Set available team sizes (pick first available one)

func _refresh_match_ending_settings() -> void:
	$Options/TimeLimit/Button.text = str(int(_current_settings.match_length)) + " s"
	$Options/GoalsToScore/Button.text = str(max(0, _current_settings.goals_to_win))
	$Options/GoalsToConcede/Button.text = str(max(0, _current_settings.goals_to_lose))

func _get_available_arenas() -> Array:
	# TODO: Filter based on game mode
	return _all_arenas

func _back() -> void:
	var scene = load("res://scenes/Title.tscn").instance()
	_main.change_scene(scene)

func _begin_match() -> void:
	if _valid_teams:
		return
	var scene = MATCH_SCENE.instance()
	scene.match_settings = _current_settings
	var player_teams := {}
	var player_colours := {}
	for i in _player_list.get_child_count():
		player_teams[i] = _player_list.get_child(i).index
		player_colours[i] = _player_list.get_child(i).get_node("TextureRect").modulate
	scene.player_teams = player_teams
	scene.player_colours = player_colours
	_main.change_scene(scene)

func _player_joined(id: int) -> void:
	InputManager.register_gamepad(id)
	var icon = PLAYER_ICON.instance()
	_player_list.add_child(icon)
	var i = 0
	var n = _current_settings.team_count
	icon.get_node("TextureRect").anchor_left = (1.0 + 2.0 * i) / (2.0 * n)
	icon.get_node("TextureRect").modulate = player_colours[id]
	# TODO: Find first available team with room

func _open_game_modifiers() -> void:
	pass
	# TODO: Have a modal that opens with fun settings. Dependant on the game mode,
	#       and the arena, and the team size, and maybe the end conditions.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
	if event.is_action_pressed("switch_team_next_DEVICE"):
		var player = _player_list.get_child(event.device)
		player.index += 1
		if player.index >= _current_settings.team_count:
			player.index = 0
		var i = player.index
		var n = _current_settings.team_count
		player.get_node("TextureRect").anchor_left = (1.0 + 2.0 * i) / (2.0 * n)
		player.get_node("TextureRect").anchor_right = (1.0 + 2.0 * i) / (2.0 * n)
	if event.is_action_pressed("switch_team_prev_DEVICE"):
		var player = _player_list.get_child(event.device)
		player.index -= 1
		if player.index < 0:
			player.index = _current_settings.team_count - 1
		var i = player.index
		var n = _current_settings.team_count
		player.get_node("TextureRect").anchor_left = (1.0 + 2.0 * i) / (2.0 * n)
		player.get_node("TextureRect").anchor_right = (1.0 + 2.0 * i) / (2.0 * n)
	if event.is_action_pressed("menu_DEVICE"):
		_begin_match()
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		var dir: int = 1 if event.is_action_pressed("ui_right") else -1
		var current_option: int = get_focus_owner().get_parent().get_index()
		match current_option:
			0:
				_change_game_mode(dir)
			1:
				_change_arena(dir)
			2:
				_change_team_size(dir)
			3:
				_change_time_limit(dir)
			4:
				_change_goals_to_score(dir)
			5:
				_change_goals_to_concede(dir)

func _change_game_mode(dir: int) -> void:
	_game_mode += dir
	if _game_mode < 0:
		_game_mode += GameMode.size()
	_game_mode %= GameMode.size()
	_refresh_game_mode()

func _change_arena(dir: int) -> void:
	# TODO: DO
	pass

func _change_team_size(dir: int) -> void:
	# TODO: DO
	pass

func _change_time_limit(dir: int) -> void:
	_current_settings.match_length += dir * 30
	_current_settings.match_length = max(0, _current_settings.match_length)
	_refresh_match_ending_settings()

func _change_goals_to_score(dir: int) -> void:
	_current_settings.goals_to_win += dir
	_current_settings.goals_to_win = max(1, _current_settings.goals_to_win)
	_refresh_match_ending_settings()

func _change_goals_to_concede(dir: int) -> void:
	_current_settings.goals_to_lose += dir
	_current_settings.goals_to_lose = max(1, _current_settings.goals_to_lose)
	_refresh_match_ending_settings()
