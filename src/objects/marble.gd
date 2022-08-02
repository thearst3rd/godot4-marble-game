extends RigidDynamicBody3D


const MAGNITUDE = 20.0
const TORQUE_MAGNITUDE = 5.0
const LOOK_SENS = Vector2(0.005, 0.005)

var look_direction := Vector3()
var look_direction_raw := look_direction

@onready var spring_arm: SpringArm3D = $SpringArm3D


func _ready() -> void:
	spring_arm.top_level = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	spring_arm.position = position
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


func _physics_process(_delta: float) -> void:
	var wishdir := Input.get_vector("left", "right", "forward", "backward")

	var force_vector := (Vector3(wishdir.x, 0, wishdir.y) * MAGNITUDE).rotated(Vector3.UP, look_direction.y)
	apply_central_force(force_vector)
	var torque_vector := (Vector3(wishdir.y, 0, -wishdir.x) * TORQUE_MAGNITUDE).rotated(Vector3.UP, look_direction.y)
	apply_torque(torque_vector)

	if Input.is_action_just_pressed("jump"):
		apply_impulse(Vector3.UP * 10)
