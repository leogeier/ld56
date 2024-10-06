#[compute]
#version 450

// https://github.com/SebLague/Boids/blob/master/Assets/Scripts/BoidCompute.compute

const int MAX_SIZE = 1024;
//const float VIEW_RADIUS = 200.0;
//const float AVOID_RADIUS = 50.0;

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

struct Boid {
	vec2 position;
	vec2 heading;
	
	vec2 flock_heading;
	vec2 flock_center;
	vec2 separation_heading;
	float num_flockmates;
	
	float is_active;
};

layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
	int num_boids;
	float view_radius;
	float avoid_radius;
	Boid boids[];
}
data_buffer;

#define BOID(i) data_buffer.boids[i]

void main() {
	uint id = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * 16;
	
	BOID(id).flock_center = BOID(id).position;
	
	for (int other_id = 0; other_id < data_buffer.num_boids; ++other_id) {
		if (id != other_id) {
			vec2 offset = BOID(other_id).position - BOID(id).position;
			float squared_dist = dot(offset, offset);
			
			if (squared_dist < data_buffer.view_radius * data_buffer.view_radius) {
				BOID(id).num_flockmates += 1.0;
				BOID(id).flock_heading += BOID(other_id).heading;
				BOID(id).flock_center += BOID(other_id).position;
				
				if (squared_dist < data_buffer.avoid_radius * data_buffer.avoid_radius) {
					BOID(id).separation_heading -= offset / squared_dist;
				}
			}
		}
	}
	
	BOID(id).flock_heading /= BOID(id).num_flockmates;
	BOID(id).flock_center /= (BOID(id).num_flockmates + 1);
	BOID(id).separation_heading /= (BOID(id).num_flockmates + 1);
	
	/*BOID(id).position.x = 1.0;
	BOID(id).position.y = 2.0;
	BOID(id).heading.x = 3.0;
	BOID(id).heading.y = 4.0;
	
	BOID(id).flock_heading.x = 5.0;
	BOID(id).flock_heading.y = 6.0;
	BOID(id).flock_center.x = 7.0;
	BOID(id).flock_center.y = 8.0;
	BOID(id).separation_heading.x = 9.0;
	BOID(id).separation_heading.y = 10.0;
	BOID(id).num_flockmates = 11.0;
	
	BOID(id).is_active = 12.0;*/
}
