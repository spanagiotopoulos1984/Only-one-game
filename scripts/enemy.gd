class_name Base_Enemy
extends CharacterBody2D

@export var resource: enemy_resource

@export var attack_radius := 0
@export var has_died := false
@onready var spear = preload("res://scenes/spear.tscn")

var enemy_node : AnimatedSprite2D
var player: Player
var animation_tree : AnimationTree

var is_shield_attack := false
var is_shield_walk := false
var is_spear_attack := false
var is_spear_walk := false

var is_spear_dying := false
var is_shield_dying := false
var death_timer : Timer
var shoot_cd : Timer
var spear_origin : Marker2D
var can_shoot := true

func _ready():
	shoot_cd = $ShootCD
	spear_origin = $"Spear Origin"
	death_timer = $DeathTimer
	attack_radius = resource.attack_radius
	enemy_node = $AnimatedSprite2D
	animation_tree = $AnimationTree
	if resource.type == resource.enemy_type.SWORDSMAN:
		is_spear_walk = false
		is_shield_walk = true
	elif resource.type == resource.enemy_type.SPEARMAN:
		is_spear_walk = true
		is_shield_walk = false
	player = get_tree().get_nodes_in_group("Player").get(0)
	shoot_cd.stop()

func _physics_process(delta: float) -> void:
	var should_move = true
	var direction = global_position.direction_to(player.global_position)
	update_animation_parameters(direction)
	
	var movement_speed = resource.movement_speed
	
	if is_spear_dying or is_shield_dying:
		velocity = Vector2.ZERO
	else:
		velocity = direction * movement_speed
		
		if direction.x > 0:
			enemy_node.flip_h = true
		elif direction.x < 0: 
			enemy_node.flip_h = false
			
		var distance = position.distance_to(player.position)
		
		if resource.type == resource.enemy_type.SWORDSMAN:
			if distance <= attack_radius:
				is_shield_attack = true
				is_shield_walk = false
			else:
				is_shield_attack = false
				is_shield_walk = true
		elif resource.type == resource.enemy_type.SPEARMAN:
			if distance <= attack_radius:
				should_move = false
				is_spear_attack = true
				is_spear_walk = false
				shoot()
			else:
				is_spear_walk = true
				is_spear_attack = false
				
		update_animation_parameters(direction)
		
		if should_move:
			move_and_collide(direction * movement_speed * delta)
	
func hurt_enemy(damage:int):
	resource.enemy_health -= damage
	if(resource.enemy_health <=0):
		death_timer.start()
		if resource.type == resource.enemy_type.SWORDSMAN:
			is_shield_dying = true
			is_shield_walk = false
		elif resource.type == resource.enemy_type.SPEARMAN:
			is_spear_dying = true
			is_spear_walk = false
		
		
func update_animation_parameters(direction):
	animation_tree["parameters/conditions/is_shield_dying"] = is_shield_dying
	animation_tree["parameters/conditions/is_spear_dying"] = is_spear_dying

	animation_tree["parameters/conditions/is_shield_attack"] = is_shield_attack
	animation_tree["parameters/conditions/is_shield_walk"] = is_shield_walk

	animation_tree["parameters/conditions/is_spear_attack"] = is_spear_attack
	animation_tree["parameters/conditions/is_spear_walk"] = is_spear_walk

	if direction != Vector2.ZERO:
		animation_tree["parameters/enemy_shield_attack/blend_position"] = direction
		animation_tree["parameters/enemy_shield_walk/blend_position"] = direction
		animation_tree["parameters/enemy_spear_attack/blend_position"] = direction
		animation_tree["parameters/enemy_spear_walk/blend_position"] = direction

func shoot():
	if can_shoot:
		var spear_proj = spear.instantiate()
		add_child(spear_proj)
		var direction  = global_position.direction_to(player.global_position)
		spear_proj.direction = direction
		spear_proj.global_position = global_position
		can_shoot = false
		shoot_cd.start()
		
func _on_death_timer_timeout() -> void:
	queue_free()

func _on_werapon_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var p = body as Player
		p._on_hurt_box_hurt(resource.damage)

func _on_shoot_cd_timeout() -> void:
	can_shoot = true
