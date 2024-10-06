extends Resource

class_name BoidParameters

@export_range(0, 500) var speed: float = 200

@export_range(0, 5, 0.1) var separation_strength: float = 1
@export_range(0, 5, 0.1) var alignment_strength: float = 1
@export_range(0, 5, 0.1) var cohesion_strength: float = 1
@export_range(0, 1000, 0.1) var max_steer_force: float = 500
@export_range(0, 1000, 0.1) var view_radius: float = 250
@export_range(0, 1000, 0.1) var avoid_radius: float = 50
