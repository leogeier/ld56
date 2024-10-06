extends Node2D

@export var circle_color = Color.WHITE
var transparent_color

var pulling = false

func _ready() -> void:
	transparent_color = circle_color.darkened(0.3)
	transparent_color.a = 0
	$Circle.modulate = transparent_color

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = event.global_position
	elif event.is_action_pressed(&"pull_bugs"):
		pulling = true
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property($Circle, "modulate", circle_color, 0.1)
	elif event.is_action_released(&"pull_bugs"):
		pulling = false
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property($Circle, "modulate", transparent_color, 0.1)

func contains(boid):
	return $Circle/Area2D.overlaps_body(boid)
