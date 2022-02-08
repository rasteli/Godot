extends Area2D

export (int) var value = 5
var picked_up = false

func _ready():
	$AnimationPlayer.play("Idle")
	connect("body_entered", self, "_on_Body_entered")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")

func _on_Body_entered(body):
	if body.is_in_group("player") and not picked_up:
		get_tree().get_current_scene().get_node("UI").add_coins(value)
		$AnimationPlayer.play("Pickup")
		$AnimationPlayer.set_deferred("disable", true)
		picked_up = true

func _on_animation_finished(name):
	if name == "Pickup":
		queue_free()
