extends KinematicBody2D
class_name BounceBody2D

export(float) var mass: float = 2.0
export(float) var friction_coefficient: float = 0.4
export(float) var bounce_coefficient: float = 0.9

var _velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(_velocity * delta)
	if collision:
		collide(collision)
	else:
		_velocity = lerp(_velocity, Vector2.ZERO, friction_coefficient * delta)

func collide(collision: KinematicCollision2D):
	if not collision.collider.has_method("bounce"):
		# Off a wall, say
		bounce(_velocity.bounce(collision.normal) * bounce_coefficient)
		return
	# Solution from here: https://www.youtube.com/watch?v=1L2g4ZqmFLQ
	var obj = collision.collider
	var m_1: float = mass
	var m_2: float = obj.mass
	var u_1: Vector2 = _velocity
	var u_2: Vector2 = obj._velocity
	var u_rel := u_1 - u_2
	var n := collision.normal.normalized()
	var e: float = bounce_coefficient * obj.bounce_coefficient
#	var e: float = min(bounce_coefficient, obj.bounce_coefficient)
	var denom := (1 / m_1) + (1 / m_2)
	var impulse_length := -((1 + e) * u_rel.dot(n)) / denom
	var impulse := n * impulse_length
	var v_1 := u_1 + impulse / m_1
	var v_2 := u_2 - impulse / m_2
	bounce(v_1)
	obj.bounce(v_2)

func bounce(new_velocity: Vector2) -> void:
	_velocity = new_velocity
