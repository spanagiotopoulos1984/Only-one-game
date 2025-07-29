extends CharacterBody2D

@onready var enemy_node = $AnimatedSprite2D
@onready var charge_cd := $ChargeCD

@export var health = 20
@export var movement_speed = 50
@export var attack_radius = 80
@export var is_charging := false
@export var is_dead := false

var is_dying := false
var is_attack := false
var is_slamming := false
var is_walking := true

var player: Player

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player").get(0)

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	update_animation_parameters(direction)
	
	if is_dying:
		velocity = Vector2.ZERO
	else:
		velocity = direction * movement_speed * delta
		
		if direction.x > 0:
			enemy_node.flip_h = true
		elif direction.x < 0: 
			enemy_node.flip_h = false
			
		var distance = position.distance_to(player.position)
		
		if distance <= attack_radius:
			is_attack = true
			is_walking = false
			is_charging = false
		elif distance > attack_radius and distance/2 < attack_radius and not charge_cd.is_stopped():
			is_attack = false
			is_walking = false
			is_charging = true
			charge(delta)
		else:
			is_attack = false
			is_walking = true
			is_charging = false
		
		update_animation_parameters(direction)
		
		move_and_collide(velocity)

func charge(delta:float):
	velocity = velocity * 2
	charge_cd.start(7)
		

func update_animation_parameters(direction):
	pass
