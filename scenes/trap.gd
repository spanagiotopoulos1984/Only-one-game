class_name Trap
extends Area2D

@export var trap_sprang = false
@onready var sprite = $AnimatedSprite2D


func _on_body_entered(body: Node2D) -> void:
	var trap_damage = 1 if trap_sprang else 3
	
	if not trap_sprang:
		sprite.play("spring")
		trap_sprang = true # Safe to do here, since damage has already been set
		
	if body.is_in_group("Player"):
		var player = body as Player
		player.on_trap_entered(trap_damage)
