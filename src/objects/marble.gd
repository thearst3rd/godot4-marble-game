extends RigidDynamicBody3D


const MAGNITUDE = 20.0
const TORQUE_MAGNITUDE = 5.0
const LOOK_SENS = Vector2(0.0025, 0.0015)

@onready var center_node: Node3D = $CenterNode
@onready var spring_arm: SpringArm3D = $CenterNode/SpringArm3D

@onready var look_direction := spring_arm.rotation
@onready var look_direction_raw := look_direction


func _ready() -> void:
	center_node.top_level = true
	center_node.position = position
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
		look_direction_raw.y -= event.relative.x * LOOK_SENS.x
		look_direction_raw.x -= event.relative.y * LOOK_SENS.y
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	# Don't normalize this vector to enable diagonal movement
	var wishdir := Vector2(Input.get_axis("left", "right"), Input.get_axis("forward", "backward"))

	var force_vector := (Vector3(wishdir.x, 0, wishdir.y) * MAGNITUDE).rotated(Vector3.UP, look_direction.y)
	apply_central_force(force_vector)
	var torque_vector := (Vector3(wishdir.y, 0, -wishdir.x) * TORQUE_MAGNITUDE).rotated(Vector3.UP, look_direction.y)
	apply_torque(torque_vector)

	if Input.is_action_pressed("jump") and is_on_floor():
		apply_impulse(Vector3.UP * 10)


# This doesn't work...
# TODO: Replace this with something functional
func is_on_floor() -> bool:
	return get_colliding_bodies().size() > 0
