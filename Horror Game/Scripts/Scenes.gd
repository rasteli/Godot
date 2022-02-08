extends Node

# Main scene
var main_menu : String = "res://Scenes/MainMenu.tscn"

# Levels
var levels : Array = []
var level1 : String = "res://Levels/Level1.tscn"

func _ready() -> void:
	levels = [
		level1
	]
