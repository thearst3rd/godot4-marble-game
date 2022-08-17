extends RigidDynamicBody3D


signal gem_collected
signal level_finished

const MOVE_FORCE = 20.0
const MOVE_TORQUE = 5.0
const LOOK_SENS = Vector2(0.0025, 0.0025)
const JUMP_IMPULSE = 13.0
const FINISH_FORCE = 10.0

var look_direction: Vector3
var look_direction_raw: Vector3

var jumping := false

var is_level_finished := false
var finish_point: Vector3

@onready var center_node: Node3D = $CenterNode
@onready var spring_arm: SpringArm3D = $CenterNode/SpringArm3D


func _ready() -> void:
	look_direction = spring_arm.global_rotation
	look_direction.z = 0.0
	look_direction_raw = look_direction
	center_node.top_level = true
	center_node.position = position
	center_node.rotation = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	center_node.position = position
	look_direction = look_direction_raw
	look_direction.y = wrapf(look_direction.y, 0, TAU)
	look_direction.x = clampf(look_direction.x, -PI/2 + 0.1, PI/2)
	look_direction_raw = look_direction
	spring_arm.rotation = look_direction


func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		get_viewport().set_input_as_handled()
		look_direction_raw.y -= event.relative.x * LOOK_SENS.x
		look_direction_raw.x -= event.relative.y * LOOK_SENS.y


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if is_level_finished:
		var diff := finish_point - position
		apply_central_force(FINISH_FORCE * diff)
		return

	# We actually don't want to normalize this vector, enabling Marble Blast style diagonal movement
	var wishdir := Vector2(Input.get_axis("left", "right"), Input.get_axis("forward", "backward"))

	var force_vector := (Vector3(wishdir.x, 0, wishdir.y) * MOVE_FORCE).rotated(Vector3.UP, look_direction.y)
	apply_central_force(force_vector)
	var torque_vector := (Vector3(wishdir.y, 0, -wishdir.x) * MOVE_TORQUE).rotated(Vector3.UP, look_direction.y)
	apply_torque(torque_vector)

	if jumping:
		if not is_on_floor(state):
			jumping = false
	elif Input.is_action_pressed("jump") and is_on_floor(state):
		# Get jump angle
		var jump_vector = Vector3.ZERO
		for contact in state.get_contact_count():
			var contact_normal := state.get_contact_local_normal(contact)
			if contact_normal.dot(Vector3.UP) > 0.5:
				jump_vector += contact_normal
		jump_vector = jump_vector.normalized()
		# We don't want a jump to go any higher if you combine it with a bounce. Dot the jump vector with the current
		# linear velocity to make the impulse smaller.
		# Also, if the factor is less than 0, that means the bounce was too high that jumping would make the ball go
		# _lower_ than it would without a jump! If that's the case, don't allow the jump
		var factor := 1.0 - (linear_velocity / JUMP_IMPULSE).dot(jump_vector)
		if factor > 0:
			jumping = true
			apply_impulse(jump_vector.normalized() * JUMP_IMPULSE * factor)


func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contact_normal := state.get_contact_local_normal(contact)
		if contact_normal.dot(Vector3.UP) > 0.5:
			return true
	return false


func _on_trigger_entered(area: Area3D) -> void:
	if area.is_in_group("finish"):
		emit_signal("level_finished")
		is_level_finished = true
		finish_point = area.get_node("CollisionShape3D").global_position
		gravity_scale = 0
		linear_damp = 3
	elif area.is_in_group("gem"):
		area.queue_free()
		emit_signal("gem_collected")
