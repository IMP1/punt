extends Control

const MATCH_SCENE = preload("res://scenes/Match.tscn")
const PLAYER_ICON = preload("res://gui/PlayerIcon.tscn")
const FONT = preload("res://gui/Font.tres")

export(Array, Color) var player_colours = [
	Color("905454"),
	Color("b28b39"),
	Color("714a8f"),
	Color("a45a78"),
	Color("3d965b"),
	Color("ffffff"),
]

var _current_arena = preload("res://data/arenas/Lake.tscn")
var _current_settings: MatchSettings = preload("res://data/3_min_match.tres")
var _valid_teams: bool = false

onready var _main = $"/root/Main"
onready var _player_list: Control = $Teams/PlayerList
onready var _team_list: Control = $Teams/TeamList

func _ready() -> void:
	InputManager.connect("gamepad_connected", self, "player_joined")
	for id in Input.get_connected_joypads():
		_player_joined(id)
	_refresh()

func _arena_changed(new_arena) -> void:
	_current_arena = new_arena
	_refresh()

func _refresh() -> void:
	for child in _team_list.get_children():
		_team_list.remove_child(child)
	for i in _current_settings.team_count:
		var num := Label.new()
		_team_list.add_child(num)
		num.text = str(i + 1)
		num.align = Label.ALIGN_CENTER
		num.size_flags_horizontal += SIZE_EXPAND
		num.set("custom_fonts/font", FONT)
	$Arena/ArenaChoice.grab_focus()

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

func _input(event: InputEvent) -> void:
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
