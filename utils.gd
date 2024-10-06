extends Node

class_name Utils

static func clamp_magnitude(vector: Vector2, magnitude: float) -> Vector2:
	if vector.length_squared() > magnitude * magnitude:
		return vector.normalized() * magnitude
	return vector
