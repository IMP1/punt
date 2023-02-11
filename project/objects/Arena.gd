extends Node2D
class_name Arena

signal goal_scored(goal, global_pos)

export(int) var teams: int = 2
export(int) var players_per_team_min: int = 1
export(int) var players_per_team_max: int = 3

func _ready() -> void:
	for goal in $Goals.get_children():
		goal.connect("ball_entered", self, "_goal_scored", [goal])

func _goal_scored(ball, goal) -> void:
	emit_signal("goal_scored", goal, ball.global_position)
