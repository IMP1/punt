extends BounceBody2D

onready var _bump_audio: AudioStreamPlayer2D = $BumpAudio

func strike(force: Vector2):
	_velocity += force

func collide(collision: KinematicCollision2D):
	.collide(collision)
	var speed = _velocity.length() / 100
	var pitch: float = clamp(speed, 0.8, 2.0)
	_bump_audio.pitch_scale = pitch
	_bump_audio.play()
