extends CanvasLayer

onready var player = $"../Player/PlayerBody"

func _ready():
	player.connect("open_map", self, "toggle_crosshair")
	GameManager.connect("enable_term", self, "set_term_count_label")

func _process(delta):
	$FPS.visible = GameManager.fps_enabled
	$CTR.visible = GameManager.ctr_enabled

	if GameManager.fps_enabled:
		var fps = Engine.get_frames_per_second()
		$FPS.text = str(fps)

func set_term_count_label() -> void:
	var term_error_count = GameManager.update_terminal_count()

	$Count.visible = true
	$Count.text = str(term_error_count)

	yield(GameManager.Tree.create_timer(2), "timeout")
	$Count.visible = false

func set_generic_label(text: String) -> void:
	$Count.visible = false
	$Generic.visible = true
	$Generic.text = text

	yield(GameManager.Tree.create_timer(4), "timeout")
	$Generic.visible = false

func set_instruction_labels(title: String, desc: String) -> void:
	if not $InstructionTimer.is_stopped():
		$InstructionTimer.stop()

	$Instruction.modulate.a = 0
	$Instruction.visible = true

	var inc = 0
	$Instruction/Title.text = title
	$Instruction/Desc.text = desc

	while $Instruction.modulate.a < 1:
		inc += 0.01
		$Instruction.modulate.a = lerp($Instruction.modulate.a, 1, inc * 2)
		yield(GameManager.Tree.create_timer(inc), "timeout")

	$InstructionTimer.start()

	yield($InstructionTimer, "timeout")

	$Instruction.visible = false

func toggle_crosshair(map: bool) -> void:
	$Crosshair.visible = not map
