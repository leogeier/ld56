extends Node

# Heavily modified from https://docs.godotengine.org/en/stable/tutorials/shaders/compute_shaders.html

const MAX_SIZE = 1024
const WORKGROUP_SIZE = 16 * 16

var VECTOR2_BYTES = PackedVector2Array([Vector2()]).to_byte_array().size()
var INT_BYTES = PackedInt32Array([0]).to_byte_array().size()
var FLOAT_BYTES = PackedFloat32Array([0.0]).to_byte_array().size()

var rd: RenderingDevice
var shader: RID
var buffer: RID
var uniform: RDUniform
var uniform_set: RID

var buffer_initialized = false

var targets = []

func _compute_frame(boids):
	var invocations = int(ceil(float(boids.size()) / WORKGROUP_SIZE))
	var boid_bytes
	
	var input_bytes = PackedInt32Array([boids.size()]).to_byte_array()
	input_bytes.append_array(PackedFloat32Array([boids.front().params.view_radius, boids.front().params.avoid_radius, 0]).to_byte_array())
	var initial_offset = input_bytes.size()
	
	for boid in boids:
		var active = 1 if boid.is_active else -1
		var packed = PackedFloat32Array([boid.global_position.x, boid.global_position.y, boid.heading.x, boid.heading.y, 0, 0, 0, 0, 0, 0, 0, active]).to_byte_array()
		#packed.resize(packed.size() + 3 * VECTOR2_BYTES + 2 * FLOAT_BYTES)
		boid_bytes = packed.size()
		input_bytes.append_array(packed)
	input_bytes.resize(2 * INT_BYTES + boid_bytes * WORKGROUP_SIZE * invocations)
	
	if (buffer_initialized):
		_update_buffer(input_bytes)
	else:
		_initialize_buffer(input_bytes)

	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, invocations, 1, 1)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	
	var output_bytes := rd.buffer_get_data(buffer)
	var output = output_bytes.to_float32_array()
	#print("Input: ", input)
	#print("Output: ", output)
	#print(output_bytes.slice(0, INT_BYTES).to_int32_array())
	for i in range(boids.size()):
		var values = output_bytes.slice(initial_offset + i * boid_bytes, initial_offset + i * boid_bytes + boid_bytes).to_float32_array()
		var boid = boids[i]
		boid.flock_heading = Vector2(values[4], values[5])
		boid.flock_center = Vector2(values[6], values[7])
		boid.separation_heading = Vector2(values[8], values[9])
		boid.num_flockmates = values[10]
		#print(values)
		#boids[i].position = Vector2(values[0], values[1])

func update_boids():
	_compute_frame(get_tree().get_nodes_in_group("boid"))

func _ready():
	rd = RenderingServer.create_local_rendering_device()
	var shader_file = load("res://scenes/boid/boid_shader.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	
	if shader_file.base_error:
		print("Shader Base Error: ", shader_file.base_error)
	if shader_spirv.compile_error_compute:
		print("Shader Compute Error: ", shader_spirv.compile_error_compute)
		
	shader = rd.shader_create_from_spirv(shader_spirv)

func _initialize_buffer(input_bytes):
	buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
	
	uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer)
	uniform_set = rd.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	
	buffer_initialized = true

func _update_buffer(input_bytes):
	rd.buffer_update(buffer, 0, input_bytes.size(), input_bytes)

#var pressed = false
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#pressed = event.pressed
		#targets = [get_tree().get_first_node_in_group(&"cursor").global_position] if pressed else []
	#if event is InputEventMouseMotion and pressed:
		#targets = [get_tree().get_first_node_in_group(&"cursor").global_position]
