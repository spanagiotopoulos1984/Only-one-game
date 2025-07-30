extends Node2D

@onready var pit = $Pit

func _ready() -> void:
	var audio_stream = $AudioStreamPlayer2D
	audio_stream.play()

func _on_pit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var p = body as Player
		p.fall(pit.position)
	elif body.is_in_group("Enemy"):
		var e = body as Base_Enemy
		e.fall(pit.position)
	elif body.is_in_group("Boss"):
		var b = body as DaBigBoss
		b.emergency_charge()
