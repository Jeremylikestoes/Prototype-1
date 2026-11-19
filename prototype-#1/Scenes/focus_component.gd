class_name FocusComponent
extends Node

@export var focus_bar: ProgressBar

var maximum_focus: float = 30.0
var minimum_focus: float = 10.0

var focus_gain_rate: float = 0.02
var focus_loss_rate: float = 0.04

func _ready() -> void:
	focus_bar.max_value = maximum_focus
	focus_bar.min_value = minimum_focus

func _gain_focus() -> void:
	focus_bar.value += focus_gain_rate

func _loose_focus() -> void:
	focus_bar.value -= focus_loss_rate
