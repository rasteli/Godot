extends Spatial

onready var letter_panel = $Letter/Panel
onready var letter_preview = $Letter/Panel/Preview

var wait_frames : int

func _ready():
	set_process(false)
	wait_frames = 1

func _process(delta):
	if wait_frames > 0:
		wait_frames = -1
		return

	if Input.is_action_just_pressed("interact"):
		open_preview()

	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.toggle_letter(self)

func open_letter():
	set_process(true)
	letter_panel.visible = true

func open_preview():
	if letter_panel.visible:
		letter_preview.visible = true

func close_letter():
	set_process(false)
	wait_frames = 1
	letter_panel.visible = false
	letter_preview.visible = false
