class_name Base_Enemy
extends CharacterBody2D

@export var resource: enemy_resource

@export var attack_radius := 0
@export var has_died := false
@onready var spear = preload("res://scenes/spear.tscn")
@onready var hurtbox = $Hurtbox

var types
var health
var movement_speed : float
var type
var damage
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
var can_play_sound = true

func _ready():
	types = resource.enemy_type
	health = resource.enemy_health
	type = resource.type
	damage = resource.damage
	attack_radius = resource.attack_radius
	movement_speed = resource.movement_speed
	shoot_cd = $ShootCD
	spear_origin = $"Spear Origin"
	death_timer = $DeathTimer
	enemy_node = $AnimatedSprite2D
	animation_tree = $AnimationTree
	if type == types.SWORDSMAN:
		is_spear_walk = false
		is_shield_walk = true
	elif type == types.SPEARMAN:
		is_spear_walk = true
		is_shield_walk = false
	player = get_tree().get_nodes_in_group("Player").get(0)
	shoot_cd.stop()

func _physics_process(delta: float) -> void:
	if not player.is_dead:
		var direction = global_position.direction_to(player.global_position)
		update_animation_parameters(direction)
		
		if is_spear_dying or is_shield_dying:
			velocity = Vector2.ZERO
		else:
			velocity = direction * movement_speed
			
			if direction.x > 0:
				enemy_node.flip_h = true
			elif direction.x < 0: 
				enemy_node.flip_h = false
				
			var distance = position.distance_to(player.position)
			
			if type == types.SWORDSMAN:
				if distance <= attack_radius:
					is_shield_attack = true
					is_shield_walk = false
					play_sound("res://audio/effects/swing.wav")
				else:
					is_shield_attack = false
					is_shield_walk = true
			elif type == types.SPEARMAN:
				if distance <= attack_radius:
					is_spear_attack = true
					is_spear_walk = false
					shoot()
				else:
					is_spear_walk = true
					is_spear_attack = false
					
			update_animation_parameters(direction)
			
			if type == types.SWORDSMAN or distance > attack_radius:
				move_and_collide(direction * movement_speed * delta)
	else:
		animation_tree.active = false
		enemy_node.play("RESET")
	
func hurt_enemy(dmg:int):
	health -= dmg
	if(health <=0):
		death_timer.start()
		if type == types.SWORDSMAN:
			is_shield_dying = true
			is_shield_walk = false
		elif type == types.SPEARMAN:
			is_spear_dying = true
			is_spear_walk = false
	else:
		play_hurt()
		
		
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
		play_sound("res://audio/effects/swing.wav")
		var spear_proj = spear.instantiate()
		var direction  = global_position.direction_to(player.global_position)
		get_tree().current_scene.add_child(spear_proj)
		spear_proj.direction = direction
		spear_proj.global_position = global_position
		can_shoot = false
		shoot_cd.start()
		
func _on_death_timer_timeout() -> void:
	player.increase_xp()
	queue_free()

func _on_werapon_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var p = body as Player
		p._on_hurt_box_hurt(damage)

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func fall(pos:Vector2) -> void:
	movement_speed = 0
	animation_tree.active = false
	enemy_node.play("RESET")
	enemy_node.global_position = pos
	
	for i in range(0,10):
		enemy_node.global_position.y += 3
		enemy_node.rotation += 90
		enemy_node.scale.x = enemy_node.scale.x -0.05
		enemy_node.scale.y = enemy_node.scale.y -0.05
		await get_tree().create_timer(0.1).timeout
	play_sound("res://audio/effects/death1.wav")
	await get_tree().create_timer(0.1).timeout
	enemy_node.visible = false
	player.increase_xp()
	queue_free()

func play_hurt() -> void:
	for i in range(0,2):
		enemy_node.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		enemy_node.modulate = Color.WHITE

func play_sound(path: String):
	var audio_stream_player  = $AudioStreamPlayer
	if can_play_sound:
		can_play_sound = false
		var stream = load(path)
		var rnd = randf_range(-0.1,0.1)
		if stream and stream is AudioStream:
			audio_stream_player.pitch_scale = 0.9 + rnd
			audio_stream_player.stream = stream
			audio_stream_player.play()
		else:
			push_warning("Invalid audio stream: " + path)
		await audio_stream_player.finished
		await get_tree().create_timer(1).timeout
		can_play_sound = true
