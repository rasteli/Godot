extends Spatial

func _ready():
	yield(GameManager.Tree.create_timer(0.1), "timeout")
	GameManager.Player.connect("interact", self, "_on_Player_interact")

func _on_Player_interact(hit: bool) -> void:
	$Interaction.visible = hit
