class_name Spear
extends Area2D

@onready var sprite :  Sprite2D
@export var speed := 600
@onready var player := Player

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

func _ready() -> void:
	sprite = $Sprite2D

func _on_flight_timer_timeout() -> void:
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	velocity = direction * speed
	rotation = direction.angle()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var p = body as Player
		p._on_hurt_box_hurt(1)
