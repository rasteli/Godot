extends Node

var loader
var wait_frames
var time_max = 100

var current_scene
var loading_scene

var loading_scene_res = preload("res://Scenes/LoadingScene.tscn")

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func go_to_scene(path):
	loading_scene = loading_scene_res.instance()
	loader = ResourceLoader.load_interactive(path)

	if loader == null:
		return

	GameManager.reset()
	current_scene.queue_free()

	set_process(true)
	set_new_scene(loading_scene)
	wait_frames = 1

func _process(delta):
	if loader == null:
		set_process(false)
		return

	if wait_frames > 0:
		wait_frames -= 1
		return

	var ticks = OS.get_ticks_msec()

	while OS.get_ticks_msec() < ticks + time_max:
		var err = loader.poll()

		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			current_scene = resource.instance()
			loader = null

			loading_scene.queue_free()
			set_new_scene(current_scene)
			break
		elif err == OK:
			update_progress()
		else:
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count() * 100
	loading_scene.get_node("ProgressBar").value = progress

func set_new_scene(scene):
	get_node("/root").add_child(scene)
