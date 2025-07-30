extends Node2D

var start_timer_cd := 180.0

@onready var start_timer: Timer

var enemy_scene = preload("res://scenes/boss_spawner.tscn")

func _ready() -> void:
	start_timer = $StartTimer
	start_timer.start(start_timer_cd)

func _on_start_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = position
	get_parent().add_child(enemy)
	queue_free()
