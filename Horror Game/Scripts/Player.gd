extends KinematicBody

signal open_map
signal enable_term

export var ACCEL = 4.5
export var DEACCEL = 16
export var MAX_SPEED = 18
export var NORMAL_SPEED = 6
export var MAX_SLOPE_ANGLE = 40
export var MOUSE_SENSITIVITY = 0.2
export var MAX_ROTATION_SPEED = 15
export var NORMAL_ROTATION_SPEED = 7

onready var camera = $CameraPivot/Camera
onready var first_col_shape = $CollisionShape1
onready var ray_cast = $CameraPivot/Camera/RayCast
onready var flashlight = $"../FlashlightHolder/SpotLight"

var speed : int
var roatation_speed : int

var map : bool
var hit : bool
var radar : bool
var crouching : bool

var has_radar : bool
var has_flashlight : bool

var action : String
var collider_root : Object

var vel = Vector3()
var dir = Vector3()

func _ready():
	speed = NORMAL_SPEED
	roatation_speed = NORMAL_ROTATION_SPEED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_flashlight(delta)

	if not map:
		process_input(delta)
		process_movement(delta)

	if Input.is_action_just_pressed("map") and has_radar:
		toggle_map_cam()

	var collider = ray_cast.get_collider()
	if collider:
		var name = collider.name

		hit = true
		collider_root = GameManager.get_node_root_node(collider, 2)

		if name == "term_error":
			action = "enable"
		elif name == "LetterBody":
			action = "read"
		elif name == "LeverBody" and not collider_root.enabled:
			action = "open"
		elif name == "FlashBody" or name == "PDABody":
			action = "pick up"
		else:
			hit = false
	else:
		hit = false

	GameManager.toggle_interact_input(hit, collider_root)
	camera.fov = GameManager.main_camera_fov
	MOUSE_SENSITIVITY = GameManager.mouse_sense

func toggle_map_cam():
	map = not map
	$OnOffMap.play()

	if map:
		emit_signal("open_map", true)

		$MapLoop.play()
		camera.clear_current(false)
		$MapCam.make_current()
	else:
		emit_signal("open_map", false)

		$MapLoop.stop()
		$MapCam.clear_current(false)
		camera.make_current()

func process_flashlight(delta):
	$"../FlashlightHolder".global_transform.origin = camera.global_transform.origin

	var cam_quat = Quat(camera.global_transform.basis.orthonormalized())
	var holder_quat = Quat($"../FlashlightHolder".global_transform.basis.orthonormalized())
	var cam_slerp_quat = holder_quat.slerp(cam_quat, delta * roatation_speed).normalized()

	$"../FlashlightHolder".global_transform.basis = Basis(cam_slerp_quat)

func process_input(delta):
	# ----------------------------------
	# Interaction
	if Input.is_action_just_pressed("interact") and hit:
		if action == "enable":
			emit_signal("enable_term")
			GameManager.enable_terminal(collider_root)
		elif action == "read":
			GameManager.toggle_letter(collider_root)
		elif action == "open":
			GameManager.enable_lever(collider_root)
		elif action == "pick up":
			GameManager.pickup(collider_root)

	# ----------------------------------
	# Radar
	if Input.is_action_just_pressed("radar") and has_radar:
		$Radar.play()
		radar = true
	if Input.is_action_just_released("radar"):
		yield(get_tree().create_timer(1.3), "timeout")
		radar = false

	GameManager.toggle_radar(delta, radar)

	# ----------------------------------
	# Crouching
	if Input.is_action_pressed("crouch"):
		crouching = true

	if Input.is_action_just_released("crouch"):
		crouching = false

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_movement_vector.x += 1

	if Input.is_action_pressed("run"):
		speed = MAX_SPEED
		roatation_speed = MAX_ROTATION_SPEED
		$Footstep.pitch_scale = lerp($Footstep.pitch_scale, 1.1, delta * ACCEL)
	if Input.is_action_just_released("run"):
		speed = NORMAL_SPEED
		roatation_speed = NORMAL_ROTATION_SPEED
		$Footstep.pitch_scale = 0.7

	if Input.is_action_just_pressed("toggle_flashlight") and has_flashlight:
		flashlight.visible = not flashlight.visible
		$"../Flashlight".play()

	input_movement_vector = input_movement_vector.normalized()

	if input_movement_vector.length() > 0 and not $Footstep.playing:
		$Footstep.play()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= speed

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

	var lerp_pos
	var pos_y = $CameraPivot.global_transform.origin.y
	if crouching:
		first_col_shape.set_deferred("disabled", true)
		lerp_pos = lerp(pos_y, -0.08, delta * 6)
	else:
		first_col_shape.set_deferred("disabled", false)
		lerp_pos = lerp(pos_y, 0.9, delta * 6)

	$CameraPivot.global_transform.origin.y = lerp_pos

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if not map:
			$CameraPivot.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = $CameraPivot.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -80, 70)
		$CameraPivot.rotation_degrees = camera_rot
