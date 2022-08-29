extends RigidDynamicBody3D


signal gem_collected
signal level_finished

const MOVE_FORCE = 20.0
const MOVE_TORQUE = 5.0
const MOUSE_LOOK_SENS = Vector2(0.0015, 0.0015)
const CONTROLLER_LOOK_SENS = Vector2(4.0, 3.0)
const JUMP_IMPULSE = 13.0
const FINISH_FORCE = 10.0

var player_controller: PlayerController = null

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

	if player_controller == null:
		set_player_controller(PlayerController.new())


func _process(delta: float) -> void:
	center_node.position = position
	# Use a workaround to use support both analog+digital actions until
	# https://github.com/godotengine/godot/issues/45628 gets merged
	var cameradir := player_controller.get_camera_direction()
	look_direction_raw.y -= CONTROLLER_LOOK_SENS.x * delta * cameradir.x
	look_direction_raw.x -= CONTROLLER_LOOK_SENS.y * delta * cameradir.y
	look_direction = look_direction_raw
	look_direction.y = wrapf(look_direction.y, 0, TAU)
	look_direction.x = clampf(look_direction.x, -PI/2 + 0.1, PI/2)
	look_direction_raw = look_direction
	spring_arm.rotation = look_direction


func _on_mouse_moved(relative: Vector2) -> void:
	look_direction_raw.y -= relative.x * MOUSE_LOOK_SENS.x
	look_direction_raw.x -= relative.y * MOUSE_LOOK_SENS.y


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if is_level_finished:
		var diff := finish_point - position
		apply_central_force(FINISH_FORCE * diff)
		return

	# We actually don't want to normalize this vector, enabling Marble Blast style diagonal movement
	# Also, use a workaround to use support both analog+digital actions until
	# https://github.com/godotengine/godot/issues/45628 gets merged
	var wishdir := player_controller.get_move_direction()
	# For unmodded controllers, expand the range
	if Global.expand_analog and wishdir.length() > 0.0:
		var ang := wrapf(wishdir.angle(), -PI/4, PI/4)
		var analog_scale := 1 / cos(ang)
		wishdir *= analog_scale
		wishdir.x = clampf(wishdir.x, -1.0, 1.0)
		wishdir.y = clampf(wishdir.y, -1.0, 1.0)

	var force_vector := (Vector3(wishdir.x, 0, wishdir.y) * MOVE_FORCE).rotated(Vector3.UP, look_direction.y)
	apply_central_force(force_vector)
	var torque_vector := (Vector3(wishdir.y, 0, -wishdir.x) * MOVE_TORQUE).rotated(Vector3.UP, look_direction.y)
	apply_torque(torque_vector)

	if jumping:
		if not is_on_floor(state):
			jumping = false
	elif player_controller.get_action("jump") and is_on_floor(state):
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


func set_player_controller(new_controller: PlayerController) -> void:
	if player_controller != null:
		player_controller.queue_free()
	player_controller = new_controller
	new_controller.connect("mouse_moved", self._on_mouse_moved)
