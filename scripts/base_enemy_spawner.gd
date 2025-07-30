extends Node2D

@export var start_timer_cd := 1.0
@export var spawn_timer_cd := 5.0
@export var shut_down_timer_cd := 5.0

@onready var start_timer: Timer
@onready var spawn_timer = $SpawnTimer
@onready var shutdown_timer = $ShutdownTimer

var enemy_scene = preload("res://scenes/base_enemy.tscn")
var spearman_res = preload("res://resources/spearman_resource.tres")
var swordsman_res = preload("res://resources/swordman_resource.tres")

func _ready() -> void:
	start_timer = $StartTimer
	start_timer.start(start_timer_cd)

func _on_timer_timeout() -> void:
	var enemy = enemy_scene.instantiate()
	var rnd = randf()
	if rnd>=0.75:
		enemy.resource = spearman_res
	else:
		enemy.resource = swordsman_res
	enemy.position = position
	get_parent().add_child(enemy)

func _on_start_timer_timeout() -> void:
	spawn_timer.start(spawn_timer_cd)

func _on_shutdown_timer_timeout() -> void:
	spawn_timer.stop()
	start_timer.stop()
	queue_free()
