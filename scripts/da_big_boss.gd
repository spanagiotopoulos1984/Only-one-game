class_name  DaBigBoss
extends CharacterBody2D

@onready var enemy_node = $AnimatedSprite2D
@onready var charge_cd = $ChargeCD
@onready var slam_cd = $SlamCD
@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer

@export var health := 50
@export var movement_speed := 140
@export var attack_radius := 80
@export var charge_coef := 5
@export var is_charging := false
@export var is_dead := false

@export var is_dying := false
@export var is_attacking := false
@export var is_slamming := false
@export var is_walking := true

var can_charge = false
var can_slam = false
var can_play_sound = true

var player: Player

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player").get(0)
	slam_cd.start()
	charge_cd.start()
	
func _physics_process(delta: float) -> void:
	if not player.is_dead:
		check_health()
		var direction = global_position.direction_to(player.global_position)
		if direction != Vector2.ZERO:
			animation_tree["parameters/attacking/blend_position"] = direction
			animation_tree["parameters/charging/blend_position"] = direction
			animation_tree["parameters/moving/blend_position"] = direction
		
		if is_dying:
			velocity = Vector2.ZERO
		else:
			velocity = direction * movement_speed * delta
			
			if direction.x > 0:
				enemy_node.flip_h = true
			elif direction.x < 0: 
				enemy_node.flip_h = false
				
			var distance = position.distance_to(player.position)

			if distance <= attack_radius and not is_attacking:
				if can_slam:
					is_slamming = true
					is_attacking = false
					slam_cd.start()
					can_slam = false
					play_sound("res://audio/effects/pain3.wav")
				else:
					is_slamming = false
					is_attacking = true
					var rnd = randf_range(-0.1,0.1)
					play_sound("res://audio/effects/metal.wav")
				is_walking = false
				is_charging = false
			else:
				if distance > attack_radius and can_charge:
					is_attacking = false
					is_walking = false
					charge(delta)
				else:
					is_attacking = false
					is_walking = true
					is_charging = false
			
			update_animation_parameters()
			move_and_collide(velocity)
	else:
		animation_tree.active = false
		enemy_node.play("default")

func charge(delta:float):
	is_charging = true
	velocity = velocity * 300 * delta
	await get_tree().create_timer(1.3).timeout
	can_charge = false
	charge_cd.start()
	play_sound("res://audio/effects/pain2.wav")
		
func update_animation_parameters():
	animation_tree["parameters/conditions/is_moving"] = is_walking
	animation_tree["parameters/conditions/is_charging"] = is_charging
	animation_tree["parameters/conditions/is_attacking"] = is_attacking
	animation_tree["parameters/conditions/is_slamming"] = is_slamming
	animation_tree["parameters/conditions/is_dying"] = is_dying

func hurt_enemy(damage:int) -> void:
	health -= damage
	play_hurt()

func check_health() -> void:
	if health <= 0:
		play_sound("res://audio/effects/death3.wav")
		movement_speed = 0
		is_attacking = false
		is_charging = false
		is_slamming = false
		is_walking = false
		is_dying = true
		animation_player.active = false
		animation_tree.active = false
		enemy_node.play("death")
		await get_tree().create_timer(3).timeout
		queue_free()

func play_hurt() -> void:
	for i in range(0,3):
		enemy_node.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		enemy_node.modulate = Color.WHITE

func _on_attack_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var p = body as Player
		p._on_hurt_box_hurt(1)
		
func _on_slam_cd_timeout() -> void:
	can_slam = true

func _on_charge_cd_timeout() -> void:
	can_charge = true

func emergency_charge():
	charge_cd.stop()
	can_charge = true
	charge(1)

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
