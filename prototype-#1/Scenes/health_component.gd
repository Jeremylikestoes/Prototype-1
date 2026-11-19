class_name HealthComponent
extends Node

@export var health_bar: ProgressBar

var maximum_health: float = 12.0
var health: float = health_bar.value

func _ready() -> void:
	health_bar.max_value = maximum_health
	
func _process(_delta: float) -> void:
	pass
