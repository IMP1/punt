extends Node2D

func _ready():
	$Particles2D.emitting = true
	$Timer.start()

func _destroy():
	queue_free()
