#@tool

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

var deviation_offset

const HALF_PI = PI / 2

var steer_strength

@onready var bug_sprite_position = $BugSprite.position

func update_sprite():
	$Headed.look_at(global_position + heading)
	var angle = heading.angle_to(Vector2.UP)
	var bank_direction = -sign(angle)
	var bank_strength = 1.0 - abs(abs(angle) - HALF_PI) / HALF_PI
	$BugSprite.rotation = params.max_bank_amount * bank_strength * bank_direction
	$BugSprite.position.y = bug_sprite_position.y + sin(deviation_offset + Time.get_ticks_msec() * 0.01) * 5

func _ready() -> void:
	deviation_offset = 2 * PI * randf()
	$BugSprite.play(&"default")
	$BugSprite.frame = randi() % 3
	$BugSprite.speed_scale = randf_range(0.9, 1.1)
	$BugSprite.scale = Vector2.ONE * randf_range(1 - params.size_variance, 1 + params.size_variance)
	steer_strength = randf_range(1 - params.steer_strength_variance, 1 + params.steer_strength_variance)

func _physics_process(delta):
	if not is_active: return
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
	
	if is_heading_for_collision():
		var collision_avoidance_force = steer_towards(calculate_avoidance_dir()) * params.avoid_collision_strength
		acceleration += collision_avoidance_force
	
	var cursor = get_tree().get_first_node_in_group(&"cursor")
	if cursor:
		if cursor.contains(self):
			acceleration += steer_towards(global_position.direction_to(cursor.global_position)) * params.target_strength
	#for target in BoidManager.targets:
		#if global_position.distance_squared_to(target) < 90000:
			#acceleration += steer_towards(global_position.direction_to(target)) * 5
	
	acceleration += steer_towards(heading.rotated(2 * PI * sin(deviation_offset + Time.get_ticks_msec() * 0.001))) * params.deviation_strength
	#acceleration += steer_towards(global_position.direction_to(Vector2(500, 500)))
	
	if global_position.x < params.avoid_edge_distance:
		acceleration += steer_towards(avoid_edge_force(Vector2.RIGHT, global_position.x)) * params.avoid_edge_strength
	if global_position.y < params.avoid_edge_distance:
		acceleration += steer_towards(avoid_edge_force(Vector2.DOWN, global_position.y)) * params.avoid_edge_strength
	if global_position.x > 1000 - params.avoid_edge_distance:
		acceleration += steer_towards(avoid_edge_force(Vector2.LEFT, 1000 - global_position.x)) * params.avoid_edge_strength
	if global_position.y > 1000 - params.avoid_edge_distance:
		acceleration += steer_towards(avoid_edge_force(Vector2.UP, 1000 - global_position.y)) * params.avoid_edge_strength
	
	var old_heading = heading
	velocity += acceleration * steer_strength
	var speed = clamp(velocity.length(), params.min_speed, params.max_speed)
	heading = velocity.normalized()
	velocity = heading * speed
	#velocity = heading * params.speed
	
	update_sprite()
	$BugSprite.scale = Vector2.ONE * clamp(inverse_lerp(0.1, 0, abs(old_heading.angle_to(heading))), 0.75, 1)
	
	move_and_slide()
	
	if debug_draw:
		queue_redraw()

func _update_heading():
	return
	#var separation_force = calculate_separation_steer()
	

func steer_towards(vector):
	var v = vector.normalized() * params.max_speed - velocity
	return Utils.clamp_magnitude(v, params.max_steer_force)

func is_heading_for_collision():
	%RayCast2D.force_raycast_update()
	return %RayCast2D.is_colliding()

func calculate_avoidance_dir():
	var steps = []
	for i in range(params.avoidance_angle_steps):
		steps.push_back(i)
		steps.push_back(-i)
	var step_angle = params.max_avoidance_angle / params.avoidance_angle_steps
	
	var furthest_collision_dist = -1
	var furthest_collision_dir = heading
	
	for step in steps:
		var angle = step_angle * step
		%RayCast2D.rotation_degrees = angle
		%RayCast2D.force_raycast_update()
		var raycast_dir = %RayCast2D.global_transform.basis_xform(Vector2.RIGHT)
		%RayCast2D.rotation = 0
		if not %RayCast2D.is_colliding():
			return raycast_dir
		
		var dist = %RayCast2D.global_position.distance_to(%RayCast2D.get_collision_point())
		if dist > furthest_collision_dist:
			furthest_collision_dist = dist
			furthest_collision_dir = raycast_dir
	
	return furthest_collision_dir

func avoid_edge_force(dir, distance_from_edge):
	var strength = params.avoid_edge_distance - distance_from_edge
	strength *= strength
	return dir * strength

func _draw():
	if not debug_draw or not flock_center: return
	
	draw_circle(Vector2.ZERO, 8, Color.GREEN)
	draw_circle(to_local(flock_center), 5, Color.RED)
	draw_circle(Vector2.ZERO, params.view_radius, Color.BLUE, false)
	draw_circle(Vector2.ZERO, params.avoid_radius, Color.RED, false)

func eat():
	is_active = false
	hide()
