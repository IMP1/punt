extends Area2D

signal ball_entered(ball)

export(int) var team: int

func _body_entered(body: Node) -> void:
	# ASSUMPTION: body will always be a ball because of the area's collision mask.
	emit_signal("ball_entered", body)
