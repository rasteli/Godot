extends CanvasLayer

onready var panel = $Panel
onready var quit_btn = $Panel/Exit
onready var resume_btn = $Panel/Resume
onready var settings_btn = $Panel/Settings
onready var settings_menu = $SettingsMenu

func _ready():
	panel.visible = false

	quit_btn.connect("pressed", self, "quit_game")
	resume_btn.connect("pressed", self, "resume_game")
	settings_btn.connect("pressed", self, "open_settings")

func resume_game():
	GameManager.toggle_pause_menu()

func open_settings():
	settings_menu.popup()

func quit_game():
	var main_menu = Scenes.main_menu
	Loader.go_to_scene(main_menu)
