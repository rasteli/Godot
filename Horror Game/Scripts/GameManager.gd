extends Node

var TerminalSuccess = preload("res://Scenes/TerminalSuccess.tscn")

var Maze : Spatial
var Tree : SceneTree
var Player : Spatial
var PauseMenu : Control

var paused : bool
var letter : bool
var ctr_enabled : bool = true
var fps_enabled : bool = false

var mouse_mode_vis : int
var mouse_mode_cap : int
var term_error_count : int
var term_success_count : int

var mouse_sense : float = 0.2
var main_camera_fov : float = 90

func _ready():
	set_process(false)
	Tree = get_tree()

	pause_mode = Node.PAUSE_MODE_PROCESS
	mouse_mode_vis = Input.MOUSE_MODE_VISIBLE
	mouse_mode_cap = Input.MOUSE_MODE_CAPTURED

func init(maze: Spatial) -> void:
	Maze = maze
	PauseMenu = Maze.get_node("../PauseMenu/Panel")
	Player = Tree.get_nodes_in_group("player")[0].get_node("PlayerBody")

	reset()
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()

	if term_error_count == 0:
		game_over()

func toggle_pause_menu() -> void:
	paused = not paused
	var mouse_mode = mouse_mode_vis if paused else mouse_mode_cap

	Tree.paused = paused
	PauseMenu.visible = paused
	Input.set_mouse_mode(mouse_mode)

func update_terminal_count() -> int:
	term_error_count -= 1
	term_success_count += 1
	return term_error_count

func toggle_interact_input(visible: bool, root: Object) -> void:
	if root:
		var interaction = root.get_node("Interaction")
		interaction.visible = visible

func enable_terminal(term_error: Object) -> void:
	var rotation = term_error.rotation_degrees
	var position = term_error.global_transform.origin

	term_error.queue_free()

	var Objective = get_node_root_node(term_error, 1)
	var term_success = TerminalSuccess.instance()
	var audio_player = term_success.get_node("TerminalBeep")

	audio_player.play()
	Objective.add_child(term_success)

	term_success.rotation_degrees = rotation
	term_success.global_transform.origin = position

	Objective.get_node("SpotLight").light_color = Color(0.13, 1, 0.13, 1)

func enable_lever(lever: Object) -> void:
	if not lever.enabled:
		lever.enable()

		var animation_player = lever.get_node("AnimationPlayer")
		var gate_animation_player = lever.get_node("../Gate/AnimationPlayer")

		animation_player.play("Open")
		gate_animation_player.connect("animation_finished", self, "_on_GateAnimation_finished")

		yield(Tree.create_timer(1), "timeout")
		gate_animation_player.play("Open")

func toggle_letter(letter_mesh: Object) -> void:
	letter = not letter

	set_process(not letter)
	Player.set_process_input(not letter)
	Player.set_physics_process(not letter)
	Player.crouching = false

	if letter:
		letter_mesh.open_letter()
	else:
		letter_mesh.close_letter()

func toggle_radar(delta: float, enabled: bool) -> void:
	var terms = Tree.get_nodes_in_group("term_error")
	var colls = Tree.get_nodes_in_group("collectible")

	for term in terms:
		var body_mesh = term.get_node("Body")
		set_shader_params(body_mesh, delta, enabled)

	for coll in colls:
		var mesh = coll.get_node("Mesh")
		set_shader_params(mesh, delta, enabled)

func pickup(object: Object) -> void:
	object.queue_free()

	var name = object.name
	var parent = get_node_root_node(Player, 1)
	var pickup_audio = parent.get_node("Pickup")
	pickup_audio.play()

	if name == "PDA":
		pickup_pda()
	elif name == "Flashlight":
		pickup_flashlight(parent)

func pickup_flashlight(parent: Object) -> void:
	Player.has_flashlight = true

	var flashlight_node = parent.get_node("FlashlightHolder")
	flashlight_node.visible = true

	var instruction_title = "You obtained Flashlight"
	var instruction_desc = "Now you can see in the dark\nPress [F] to toggle on/off"

	Maze.get_node("../UI").set_instruction_labels(instruction_title, instruction_desc)

func pickup_pda() -> void:
	Player.has_radar = true

	var instruction_title = "You obtained Radar"
	var instruction_desc = "Press [Q] to see items of interest\nPress [Tab] to open the map"

	Maze.get_node("../UI").set_instruction_labels(instruction_title, instruction_desc)


func set_shader_params(mesh: MeshInstance, delta: float, enabled: bool) -> void:
	var material = mesh.get_surface_material(0).next_pass

	var speed_on = lerp(material.get_shader_param("speed"), 1, delta / 10)
	var speed_off = lerp(material.get_shader_param("speed"), 0, delta * 2)

	material.set_shader_param("enabled", 1 if enabled else 0)
	material.set_shader_param("speed", speed_on if enabled else speed_off)

func reset() -> void:
	set_process(false)

	paused = false
	Tree.paused = false
	term_success_count = 0
	term_error_count = Tree.get_nodes_in_group("term_error").size()

func game_over() -> void:
	var main_menu = Scenes.main_menu
	Input.set_mouse_mode(mouse_mode_vis)
	Loader.go_to_scene(main_menu)

func get_node_root_node(node: Object, levels: int) -> Object:
	var root = node

	for n in levels:
		root = root.get_parent()

	return root

func _on_GateAnimation_finished(_anim: String) -> void:
	var inc = 0
	var wind_audio = Maze.get_node("Wind")
	wind_audio.play()

	while wind_audio.volume_db < 0:
		inc += 0.01
		wind_audio.volume_db = lerp(wind_audio.volume_db, 0, inc * 2)
		yield(Tree.create_timer(inc), "timeout")
