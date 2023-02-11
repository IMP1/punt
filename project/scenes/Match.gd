extends Node2D

signal strike(player, pos, direction)
signal collision(obj_1, obj_2)

const PLAYER = preload("res://objects/Player.tscn")
const RIPPLE = preload("res://objects/Ripple.tscn")
const SCORE = preload("res://gui/Score.tscn")
const RESET_DURATION = 0.3

export(Resource) var match_settings
export(Dictionary) var player_teams # player_id => team_id
export(Dictionary) var player_colours # player_id => colour

var _scores: Dictionary = {}
var _out_of_play: bool = true
var _timer: float = 0.0

onready var arena: Arena = $Arena.get_child(0) as Arena
onready var _goal_anim: Particles2D = $Celebration as Particles2D
onready var _fanfare: AudioStreamPlayer = $Celebration/CanvasLayer/Audio as AudioStreamPlayer
onready var _goal_sound: AudioStreamPlayer2D = $Celebration/GoalAudio as AudioStreamPlayer2D
onready var _player_list: Node2D = $Objects/Players as Node2D
onready var _clock: Label = $MatchInfo/Clock as Label
onready var _reset_tween: Tween = $ResetTween as Tween

func _ready() -> void:
	$Celebration/CanvasLayer.visible = false
	arena.connect("goal_scored", self, "_goal_scored")
	for player in $Objects/Players.get_children():
		player.connect("punt", self, "_punt")
	if match_settings == null:
		match_settings = load("res://data/3_min_match.tres")
	_setup()
	_reset(false)

func _setup() -> void:
	for team in match_settings.team_count:
		var score := SCORE.instance()
		$MatchInfo/Score.add_child(score)
		score.text = str(0)
		score.name = str(team)
		_scores[team] = 0
		if match_settings.goals_to_lose > 0:
			_scores[team] = match_settings.goals_to_lose
	for player in player_teams:
		var p: KinematicBody2D = PLAYER.instance()
		_player_list.add_child(p)
		p.colour = player_colours[player]
		p.device_id = player
		p.connect("punt", self, "_punt")
	if match_settings.match_length > -1:
		_clock.text = str(match_settings.match_length)
		_timer = match_settings.match_length

func _reset(transition=true) -> void:
	var duration = RESET_DURATION
	if not transition:
		duration = 0.0
	for i in $Objects/Balls.get_child_count():
		var ball: Node2D = $Objects/Balls.get_child(i)
		var pos: Vector2
		if arena.get_node("BallStart").get_child_count() == 1:
			pos = arena.get_node("BallStart").get_child(0).position
		elif arena.get_node("BallStart").get_child_count() > 1:
			pos = arena.get_node("BallStart").get_child(i).position
		else:
			pos = Vector2.ZERO
		ball._velocity = Vector2.ZERO
		_reset_tween.interpolate_property(ball, "position", ball.position, pos, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	for i in _player_list.get_child_count():
		var player = _player_list.get_child(i)
		player._velocity = Vector2.ZERO
		player.input_disabled = true
		var pos: Vector2 = arena.get_node("PlayerStarts").get_node(str(match_settings.players_per_team)).get_child(i).position
		_reset_tween.interpolate_property(player, "position", player.position, pos, duration, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_reset_tween.start()
	# TODO: Some screen effect? To emphasise the transition
	yield(_reset_tween, "tween_all_completed")
	_out_of_play = false
	for player in _player_list.get_children():
		player.input_disabled = false

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		_goal_scored($Arena/Lake/Goals/Goal, $Objects/Balls/Ball.global_position)

func _goal_scored(goal: Node2D, global_pos: Vector2) -> void:
	if _out_of_play:
		return
	_goal_anim.global_position = global_pos
	_goal_anim.emitting = true
	_goal_sound.play()
	_fanfare.play()
	var offset: int = -1 if match_settings.goals_to_lose > 0 else 1
	_scores[goal.team] += offset
	$MatchInfo/Score.get_node(str(goal.team)).text = str(_scores[goal.team])
	# TODO: Count score
	$Celebration/CanvasLayer.visible = true
	$Celebration/AnimationPlayer.play("Goal")
	yield($Celebration/AnimationPlayer, "animation_finished")
	$Celebration/AnimationPlayer.play("ResetPositions")
	_reset()
	yield($Celebration/AnimationPlayer, "animation_finished")
	$Celebration/CanvasLayer.visible = false

func _punt(glob_pos: Vector2) -> void:
	var ripple := RIPPLE.instance()
	$Ripples.add_child(ripple)
	ripple.global_position = glob_pos

func _process(delta: float) -> void:
	_update_clock(delta)

func _update_clock(delta: float) -> void:
	if match_settings.match_length == -1:
		_timer += delta
	else:
		_timer -= delta
		if _timer <= 0:
			_timer = 0
			_end_game()
	_clock.text = str(floor(_timer))

func _end_game() -> void:
	print("Game over")
	# TODO: Show scores and stats and stuff
	pass
