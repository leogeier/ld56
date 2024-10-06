extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(250):
		var boid = preload("res://scenes/boid/boid.tscn").instantiate()
		add_child(boid)
		boid.position = Vector2.ONE * 200 + Vector2.ONE * 600 * Vector2(randf(), randf())
		boid.heading = Vector2(randf(), randf()).normalized()
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	#BoidManager.update_boids()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	BoidManager.update_boids()
	var boids_remain = get_tree().get_nodes_in_group(&"boid").any(func(boid): return boid.is_active)
	if boids_remain:
		var time = Time.get_ticks_msec()
		var minutes = time / 60000
		var seconds = (time / 1000) % 60
		var milliseconds = time % 1000
		$TimeLabel.text = "%02d:%02d.%d" % [minutes, seconds, milliseconds]
	if not boids_remain and $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
