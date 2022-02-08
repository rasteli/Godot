extends Area2D

func _ready():
	$AnimationPlayer.play("Idle")
	connect("body_entered", self, "_on_Body_entered")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")

func _on_Body_entered(body):
	if body.is_in_group("player"):
		get_tree().get_current_scene().get_node("Player").refuel()

		$AnimationPlayer.play("Pickup")
		$AnimationPlayer.set_deferred("disable", true)

func _on_animation_finished(name):
	if name == "Pickup":
		queue_free()
