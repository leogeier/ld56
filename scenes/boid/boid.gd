@tool

extends CharacterBody2D

## Boid implementation, see
## https://en.wikipedia.org/wiki/Boids
## https://dl.acm.org/doi/10.1145/37401.37406
## https://github.com/SebLague/Boids

@export var params: BoidParameters

@export var heading = Vector2.RIGHT

@export var debug_draw = false

var is_active = true

var flock_heading
var flock_center
var separation_heading
var num_flockmates

func update_sprite():
	$Sprite2D.look_at(global_position + heading)

func _physics_process(delta):
	if Engine.is_editor_hint():
		update_sprite()
		return
	
	var acceleration = Vector2.ZERO
	
	if num_flockmates > 0.1:
		var offset_to_center = flock_center - global_position
		
		var alignment_force = steer_towards(flock_heading) * params.alignment_strength
		var cohesion_force = steer_towards(offset_to_center) * params.cohesion_strength
		var separation_force = steer_towards(separation_heading) * params.separation_strength
		
		acceleration += alignment_force + cohesion_force + separation_force
	
	velocity += acceleration
	if velocity.length() > params.speed:
		velocity = velocity.normalized() * params.speed
	heading = velocity.normalized()
	#velocity = heading * params.speed
	
	update_sprite()
	
	move_and_slide()
	
	if debug_draw:
		queue_redraw()

func _update_heading():
	return
	#var separation_force = calculate_separation_steer()
	

func steer_towards(vector):
	var v = vector.normalized() * params.speed - velocity
	return Utils.clamp_magnitude(v, params.max_steer_force)

func _draw():
	if not debug_draw or not flock_center: return
	
	draw_circle(Vector2.ZERO, 8, Color.GREEN)
	draw_circle(to_local(flock_center), 5, Color.RED)
	draw_circle(Vector2.ZERO, params.view_radius, Color.BLUE, false)
	draw_circle(Vector2.ZERO, params.avoid_radius, Color.RED, false)
