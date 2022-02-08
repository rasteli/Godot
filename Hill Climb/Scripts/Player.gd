extends RigidBody2D

export var torque = 50000
export var max_speed = 50

var fuel = 100
var wheels = []
var dead = false
var driving = 0
onready var UI = get_tree().get_current_scene().get_node("UI")

func _ready():
	wheels = get_tree().get_nodes_in_group("wheels")
	$GameOverTimer.connect("timeout", self, "game_over")
	UI.update_fuel(fuel)

func _physics_process(delta):
	driving = 0
	print(fuel)

	if fuel != 0 and not dead:
		$GameOverTimer.stop()

		if Input.is_action_pressed("ui_right"):
			driving += 1
			apply_torque_impulse(4000 * delta * 60)

			for wheel in wheels:
				if wheel.angular_velocity < max_speed:
					wheel.apply_torque_impulse(torque * delta * 60)

		if Input.is_action_pressed("ui_left"):
			driving += 1
			apply_torque_impulse(-2000 * delta * 60)

			for wheel in wheels:
				if wheel.angular_velocity > -max_speed:
					wheel.apply_torque_impulse(-torque * delta * 60)
	else:
		if $GameOverTimer.is_stopped():
			$GameOverTimer.start()
		$Engine.pitch_scale = lerp($Engine.pitch_scale, 0, 2 * delta)
		$Engine.volume_db = lerp($Engine.volume_db, -50, delta / 2)

	if driving == 1:
		use_fuel(delta)
		$Engine.pitch_scale = lerp($Engine.pitch_scale, 2, 2 * delta)
	else:
		$Engine.pitch_scale = lerp($Engine.pitch_scale, 1, 2 * delta)

	var head_rot = $Character/Head.rotation_degrees
	if	head_rot > 90 or head_rot < -90 and not dead:
		dead = true
		$Character/Head/HeadSpring.node_b = ""

func use_fuel(delta):
	fuel -= 10 * delta
	fuel = clamp(fuel, 0, 100)
	UI.update_fuel(fuel)

func refuel():
	fuel = 100
	UI.update_fuel(fuel)

func game_over():
	get_tree().reload_current_scene()
