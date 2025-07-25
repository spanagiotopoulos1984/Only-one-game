extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer

func tempdisable():
	collision.call_deferred("set","disabled", true)
	disableTimer.start()


func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set","disabled", false)
