extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_active: return
	body.eat()
	if $Timer.is_stopped():
		var sound = $Noms.get_children().pick_random()
		sound.stop()
		sound.play()
		$Timer.start()
