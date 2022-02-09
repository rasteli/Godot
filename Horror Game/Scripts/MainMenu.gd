extends CanvasLayer

onready var quit_btn = $Panel/Quit
onready var start_btn = $Panel/Start
onready var settings_btn = $Panel/Settings

onready var settings_bg = $SettingsBG
onready var settings_menu = $SettingsMenu

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	quit_btn.connect("pressed", self, "quit_game")
	start_btn.connect("pressed", self, "new_game")
	settings_btn.connect("pressed", self, "open_settings")
	settings_menu.connect("popup_hide", self, "close_settings")

func new_game():
	var level1 = Scenes.levels[0]
	Loader.go_to_scene(level1)

func open_settings():
	settings_menu.popup()
	settings_bg.visible = true

func close_settings():
	settings_bg.visible = false

func quit_game():
	get_tree().quit()
