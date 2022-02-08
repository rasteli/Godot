extends KinematicBody

var path = []
var path_index = 0

var speed : int = 13
var threshold : float = 0.1
var term_threshold : int = 5
var chasing : bool = false

onready var nav = get_parent()
onready var ui = $"../../../UI"
onready var player = $"../../../Player/PlayerBody"

func _ready():
	$CooldownTimer.connect("timeout", self, "_on_CooldownTimer_timeout")
	$ChasingTimer.connect("timeout", self, "stop_chasing")

func _physics_process(delta):
	if GameManager.term_success_count == term_threshold and not chasing:
		term_threshold = 1
		start_chasing(true)

	if GameManager.term_error_count == term_threshold and not chasing:
		start_chasing(false)

	if path.size() > 0 and chasing:
		move_to_target()

func move_to_target():
	if path_index >= path.size():
		return

	if global_transform.origin.distance_to(path[path_index]) < threshold:
		path_index += 1
	else:
		var collider = $RayCast.get_collider()
		var direction = (path[path_index] - global_transform.origin).normalized()

		if collider and collider.name == "PlayerBody":
			GameManager.game_over()

		move_and_slide(direction * speed, Vector3.UP)
		look_at(path[path_index], Vector3.UP)

func get_target_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_index = 0

func start_chasing(stoppable: bool):
	chasing = true

	if not $ChaseMusic.playing:
		$ChaseMusic.play()

	visible = true
	global_transform.origin = player.get_node("EnemySpawner").global_transform.origin

	ui.set_generic_label("RUN")
	yield(get_tree().create_timer(2), "timeout")

	$RayCast.enabled = true

	if stoppable:
		$ChasingTimer.start()
	$CooldownTimer.start()

func stop_chasing():
	visible = false
	chasing = false
	$RayCast.enabled = false

	$ChaseMusic.stop()
	$CooldownTimer.stop()

func _on_CooldownTimer_timeout():
	get_target_path(player.global_transform.origin)
