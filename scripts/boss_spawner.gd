extends Node2D

var enemy_scene = preload("res://scenes/da_big_boss.tscn")


func _ready():
	var timer = $StartTimer
	timer.autostart = true
	timer.start(60)

func _on_start_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = position
	get_tree().current_scene.add_child(enemy)
	queue_free()
