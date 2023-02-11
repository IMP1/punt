extends BounceBody2D

signal punt(global_pos)
signal strike(global_pos, direction)
signal collide(global_pos, other_obj)

enum SwipeState { None, Swiping, Holding, Controlling }

const NO_DEVICE = -1
const BUMP_SOUND = preload("res://assets/sounds/bump1.ogg")

export(Color) var colour: Color = Color.white setget _set_colour
export(int) var device_id: int = NO_DEVICE
export(float) var movement_impulse: float = 100.0
export(float) var strike_strength: float = 400.0
export(bool) var input_disabled: bool = false

var _direction: Vector2 = Vector2.ZERO
var _swipe_state: int = SwipeState.None
var _is_ready: bool = false

onready var _input_manager: InputManager = $"/root/InputManager"

onready var _bar: Node2D = $Bar as Node2D
onready var _tween: Tween = $Tween as Tween
onready var _bump_audio: AudioStreamPlayer2D = $BumpAudio as AudioStreamPlayer2D
onready var _swish_audio: AudioStreamPlayer2D = $Bar/SwishAudio as AudioStreamPlayer2D
onready var _strike_audio: AudioStreamPlayer2D = $Bar/StrikeAudio as AudioStreamPlayer2D
onready var _punt_audio: AudioStreamPlayer2D = $Bar/PuntAudio as AudioStreamPlayer2D
onready var _player_colour: Sprite = $Boat/PlayerIndicator as Sprite

func _ready():
	if device_id >= 0:
		_input_manager.register_device(device_id)
	_player_colour.modulate = colour
	_is_ready = true

func _set_colour(new_colour: Color) -> void:
	colour = new_colour
	if not _is_ready:
		return
	_player_colour.modulate = colour

func _set_device(new_device: int) -> void:
	device_id = new_device
	if not _is_ready:
		return
	_input_manager.register_device(device_id)

func _is_action_down(action_name: String) -> bool:
	return Input.is_action_pressed(action_name + "_" + str(device_id))

func _is_action_just_released(action_name: String) -> bool:
	return Input.is_action_just_released(action_name + "_" + str(device_id))

func _is_event_action_pressed(event: InputEvent, action_name: String) -> bool:
	return event.is_action_pressed(action_name + "_" + str(device_id))

func _is_event_action_released(event: InputEvent, action_name: String) -> bool:
	return event.is_action_released(action_name + "_" + str(device_id))

func _action_strength(action_name: String) -> float:
	return Input.get_action_strength(action_name + "_" + str(device_id))

func _input(event: InputEvent) -> void:
	if device_id == NO_DEVICE:
		return
	if input_disabled:
		return
	if _is_event_action_pressed(event, "move"):
		_punt()
	if  _is_event_action_pressed(event, "swipe"):
		_swipe()
	if _is_event_action_released(event, "swipe"):
		_end_swipe()

func _punt() -> void:
	if _swipe_state != SwipeState.None:
		return
	_velocity += _direction * movement_impulse
	var speed = _velocity.length() / 100
	var pitch: float = clamp(speed, 0.8, 2.0)
	_punt_audio.pitch_scale = pitch
	_punt_audio.play()
	emit_signal("punt", $Bar/Tip.global_position)

func _tween_completed(obj: Object, path: NodePath) -> void:
	if obj != _bar:
		return
	match _swipe_state:
		SwipeState.Swiping:
			_on_swipe_ended()
		SwipeState.Controlling:
			_on_swipe_release_ended()

func _swipe() -> void:
	if not (_swipe_state == SwipeState.None or _swipe_state == SwipeState.Controlling):
		return
	_swipe_state = SwipeState.Swiping
	_tween.stop_all()
	_tween.interpolate_property(_bar, "rotation_degrees", _bar.rotation_degrees, -180, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()
	_swish_audio.play()

func _end_swipe() -> void:
	if _swipe_state != SwipeState.Holding:
		return
	_control_swipe()

func _on_swipe_ended() -> void:
	if _is_action_down("swipe"):
		_swipe_state = SwipeState.Holding
		_tween.stop_all()
		_tween.interpolate_property(_bar, "position", _bar.position, Vector2(6, -10), 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		_tween.interpolate_property(_bar, "rotation_degrees", _bar.rotation_degrees, -90, 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		_tween.start()
		bounce_coefficient = 0.4
	else:
		_control_swipe()

func _control_swipe() -> void:
	_swipe_state = SwipeState.Controlling
	_tween.stop_all()
	_tween.interpolate_property(_bar, "position", _bar.position, Vector2(0, 0), 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN)
	_tween.interpolate_property(_bar, "rotation_degrees", _bar.rotation_degrees, 0, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN)
	_tween.start()
	bounce_coefficient = 0.9

func _on_swipe_release_ended() -> void:
	_swipe_state = SwipeState.None

func _on_swipe_hit(ball: KinematicBody2D) -> void:
	match _swipe_state:
		SwipeState.None:
			return
		SwipeState.Swiping:
			ball.strike(_direction * strike_strength)
			emit_signal("strike", ball.global_position, _direction)
			_strike_audio.play()
		SwipeState.Holding:
			print("holding impact")
			# TODO: Minor (Controlled) Reflection
			pass
		SwipeState.Controlling:
			# TODO: Control ball
			pass

func _process(_delta: float) -> void:
	if device_id == NO_DEVICE:
		return
	if input_disabled:
		return
	var velocity := Vector2.ZERO
	velocity.x = _action_strength("right") - _action_strength("left")
	velocity.y = _action_strength("down") - _action_strength("up")
	if velocity != Vector2.ZERO:
		_direction = velocity.normalized()
		rotation_degrees = rad2deg(_direction.angle())

func collide(collision: KinematicCollision2D):
	.collide(collision)
	emit_signal("collide", collision.position, collision.collider)
	# TODO: Factor out audio code into separate class
	var speed = _velocity.length() / 100
	var pitch: float = clamp(speed, 0.8, 2.0)
	_bump_audio.stream = BUMP_SOUND
	_bump_audio.pitch_scale = pitch
	_bump_audio.play()
	Input.start_joy_vibration(device_id, 0.5, 0.5, 0.3)
