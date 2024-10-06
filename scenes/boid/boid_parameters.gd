extends Resource

class_name BoidParameters

@export_range(0, 500) var max_speed: float = 200
@export_range(0, 500) var min_speed: float = 50

@export_range(0, 5, 0.1) var separation_strength: float = 1
@export_range(0, 5, 0.1) var alignment_strength: float = 1
@export_range(0, 5, 0.1) var cohesion_strength: float = 1
@export_range(0, 5, 0.1) var avoid_collision_strength: float = 1
@export_range(0, 5, 0.1) var deviation_strength: float = 1
@export_range(0, 5, 0.1) var avoid_edge_strength: float = 1
@export_range(0, 10, 0.1) var target_strength: float = 1
@export_range(0.5, 1000, 0.1) var max_steer_force: float = 500
@export_range(0, 1000, 0.1) var view_radius: float = 250
@export_range(0, 1000, 0.1) var avoid_radius: float = 50
@export_range(0, 90, 0.1) var max_avoidance_angle: float = 45
@export_range(0, 10) var avoidance_angle_steps: int = 4
@export_range(0, 200, 0.1) var avoid_edge_distance: int = 50
@export_range(0, 0.5, 0.01) var steer_strength_variance: float = 0.1

@export_range(0, PI, 0.01) var max_bank_amount: float = PI / 2
@export_range(0, 0.5, 0.01) var size_variance: float = 0.1
