extends Node2D

var tween

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_active: return
	body.eat()
	if $Timer.is_stopped():
		var sound = $Noms.get_children().pick_random()
		sound.stop()
		sound.play()
		$Timer.start()
	
	if tween:
		tween.kill()
	$Frog.scale = Vector2.ONE * 1.1
	$Frog.rotation = randf_range(-0.15, 0.15)
	tween = create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Frog, "scale", Vector2.ONE, 0.5)
	tween.tween_property($Frog, "rotation", 0, 0.5)
