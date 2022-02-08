extends Popup

# Video buttons
onready var window_opt_btn = $TabC/Video/MarginC/GridC/WindowOptBtn
onready var vsync_btn = $TabC/Video/MarginC/GridC/VsyncButton
onready var display_fps_btn = $TabC/Video/MarginC/GridC/DisplayFPSBtn
onready var display_ctr_btn = $TabC/Video/MarginC/GridC/DisplayCTRBtn

# Audio sliders
onready var master_slider = $TabC/Audio/MarginC/GridC/MasterSlider
onready var music_slider = $TabC/Audio/MarginC/GridC/MusicSlider
onready var sfx_slider = $TabC/Audio/MarginC/GridC/SFXSlider

# Gameplay sliders
onready var fov_slider = $TabC/Gameplay/MarginC/GridC/FOVSlider
onready var mouse_sen_slider = $TabC/Gameplay/MarginC/GridC/MouseSenSlider

# Audio bus
var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready():
	# Video signals
	vsync_btn.connect("toggled", self, "toggle_vsync")
	display_fps_btn.connect("toggled", self, "toggle_fps")
	display_ctr_btn.connect("toggled", self, "toggle_ctr")
	window_opt_btn.connect("item_selected", self, "select_window_mode")
	# Audio signals
	sfx_slider.connect("value_changed", self, "set_sfx")
	music_slider.connect("value_changed", self, "set_music")
	master_slider.connect("value_changed", self, "set_master")
	# Gameplay signals
	fov_slider.connect("value_changed", self, "set_fov")
	mouse_sen_slider.connect("value_changed", self, "set_mouse_sense")

func set_bus_volume(bus_index: int, volume: float):
	AudioServer.set_bus_volume_db(bus_index, volume)

# Video functions
func toggle_vsync(enabled: bool):
	OS.vsync_enabled = enabled

func toggle_fps(enabled: bool):
	GameManager.fps_enabled = enabled

func toggle_ctr(enabled: bool):
	GameManager.ctr_enabled = enabled

func select_window_mode():
	pass

# Audio functions
func set_sfx(value: float):
	set_bus_volume(sfx_bus, value)

func set_music(value: float):
	set_bus_volume(music_bus, value)

func set_master(value: float):
	set_bus_volume(master_bus, value)

# Gameplay functions
func set_fov(value: float):
	GameManager.main_camera_fov = value

func set_mouse_sense(value: float):
	GameManager.mouse_sense = value
