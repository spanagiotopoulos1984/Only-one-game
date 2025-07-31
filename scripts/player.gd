class_name Player
extends CharacterBody2D 

var max_health = 20

@export var speed := 200
@export var dash_range := 2.0
@export var dash_cd := 3.0
@export var player_health = max_health
@export var selected_weapon = WEAPONS.AXE
@export var base_damage = 1

var player_level = 0
var player_xp = 0
var xp_per_lvl = 5
var max_lvl = 5
var regen_time = 8

@onready var dash_timer := $"UI Transform/Dash/Dash Timer"
@onready var dash_duration := $"UI Transform/Dash/Dash Duration"
@onready var dash_pb := $"UI Transform/Dash/Dash PB"
@onready var animation_tree := $AnimationTree
@onready var health_pb := $"UI Transform/Health/Health PB"
@onready var died_text := $"UI Transform/DiedText"
@onready var player_node := $AnimatedSprite2D
@onready var weapon_hitbox := $WeaponArea
@onready var blood_animation := $Blood_Splatter
@onready var regen_timer := $RegenTimer

var can_play_sound := true

# Weapon enum
enum WEAPONS {AXE, HAMMER}

var last_known_direction := Vector2.ZERO

# Movement booleans
var is_axe_idle := true
var is_axe_moving := false
var is_axe_lattack := false
var is_axe_rattack := false
var is_dashing := false
var is_dead := false

func _ready() -> void:
	dash_pb.min_value = 0
	dash_timer.wait_time = dash_cd
	dash_pb.max_value = dash_cd
	dash_pb.value = dash_cd
	health_pb.value = player_health
	health_pb.max_value = player_health
	died_text.visible = false
	animation_tree.active = true

func _process(_delta: float) -> void:
	update_animation_parameters()

func _physics_process(delta: float) -> void:
	process_movement_input(delta)
	process_movement_animation()
	process_action_input()
	
	update_dash_pb()
	update_health_pb()

func process_movement_input(delta):
	check_victory_condition()
	if player_health <=0:
		is_dead = true
		#death_sound_player.play()
	else:
		is_dead = false
		
	if is_dead:
		velocity = Vector2.ZERO
		died_text.text = "Press left Mouse button to restart"
		if Input.is_action_just_pressed("primary_attack"):
			get_tree().reload_current_scene()
	else:
		var direction = Input.get_vector("move_left","move_right","move_forward","move_back")
		direction = direction.normalized()
			
		if direction.x > 0 :
			player_node.flip_h = false
			weapon_hitbox.scale.x = 1
		elif direction.x < 0:
			player_node.flip_h = true
			weapon_hitbox.scale.x = -1
		else:
			if direction.y !=0:
				weapon_hitbox.position.x = 0
			else:
				weapon_hitbox.position.x = 0
		
		if direction != Vector2.ZERO:
			animation_tree["parameters/Axe_Idle/blend_position"] = direction
			animation_tree["parameters/Axe_Light_Attack/blend_position"] = direction
			animation_tree["parameters/Axe_walk/blend_position"] = direction
			animation_tree["parameters/Axe_Right_Attack/blend_position"] = direction
			animation_tree["parameters/Dash/blend_position"] = direction
		
		velocity = direction * speed * (dash_range if is_dashing else 1) * delta
		
		if dash_duration.is_stopped():
			is_dashing = false
			
		move_and_collide(velocity)
	
	
func process_action_input():
	if Input.is_action_just_pressed("primary_attack"):
		if selected_weapon == WEAPONS.AXE:
			switch_to_axe_lattack()
	else:
		is_axe_lattack  = false
	if Input.is_action_just_pressed("secondary_attack"):
		if selected_weapon == WEAPONS.AXE:
			switch_to_axe_rattack()
	else:
		is_axe_rattack = false
	if Input.is_action_just_pressed("dash"):
		if dash_timer.is_stopped() and velocity != Vector2.ZERO:
			is_dashing = true
			dash_duration.start()
			dash_timer.start()
	
func update_dash_pb():
	if not dash_timer.is_stopped():
		dash_pb.value = dash_timer.wait_time - dash_timer.time_left
		
func update_health_pb():
	health_pb.value = player_health
	if(player_health<=0):
		is_dead = true
		died_text.visible = true

func process_movement_animation():
	if velocity == Vector2.ZERO:
		if selected_weapon == WEAPONS.AXE:
			switch_to_axe_idle()
	else:
		if selected_weapon == WEAPONS.AXE:
			switch_to_axe_moving()
		
func update_animation_parameters():
	animation_tree["parameters/conditions/is_axe_idle"] = is_axe_idle
	animation_tree["parameters/conditions/is_axe_lattack"] = is_axe_lattack
	animation_tree["parameters/conditions/is_axe_move"] = is_axe_moving
	animation_tree["parameters/conditions/is_axe_rattack"] = is_axe_rattack
	animation_tree["parameters/conditions/is_dashing"] = is_dashing
	animation_tree["parameters/conditions/is_dead"] = is_dead

func switch_to_axe_idle() -> void:
	is_axe_idle = true
	is_axe_moving = false
	
func switch_to_axe_moving() -> void:
	is_axe_idle = false
	is_axe_moving = true
	
func switch_to_axe_lattack() -> void:
	base_damage = 1
	is_axe_lattack  = true
	play_sound("res://audio/effects/swing.wav")
	
func switch_to_axe_rattack() -> void:
	is_axe_rattack  = true
	base_damage = 3
	play_sound("res://audio/effects/swing.wav")

func _on_hurt_box_hurt(dmg: Variant) -> void:
	player_health -= dmg
	blood_animation.play("default")
	play_hurt()
	
func on_trap_entered(dmg: int):
	player_health -= dmg
	blood_animation.play("default")
	play_hurt()

func _on_weapon_area_body_entered(body: Node2D) -> void:
	play_sound("res://audio/effects/pain1.wav")
	if body.is_in_group("Enemy"):
		var enemy = body as Base_Enemy
		enemy.hurt_enemy(base_damage + player_level)
	elif body.is_in_group("Boss"):
		var enemy = body as DaBigBoss
		enemy.hurt_enemy(base_damage + player_level)

func play_hurt() -> void:
	play_sound("res://audio/effects/pain2.wav")
	for i in range(0,2):
		player_node.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		player_node.modulate = Color.WHITE
		
		
func fall(pos:Vector2) -> void:
	speed = 0
	animation_tree.active = false
	player_node.play("RESET")
	player_node.global_position = pos
	
	for i in range(0,10):
		player_node.global_position.y += 3
		player_node.rotation += 90
		player_node.scale.x = player_node.scale.x -0.05
		player_node.scale.y = player_node.scale.y -0.05
		await get_tree().create_timer(0.1).timeout
		
	player_node.visible = false
	player_health = 0

func check_victory_condition():
	var enemy = get_tree().get_nodes_in_group("Enemy").size()
	var boss = get_tree().get_nodes_in_group("Boss").size()
	if enemy ==0 and boss ==0:
		died_text.text = "Victory!"
		died_text.visible = true
		get_tree().paused = true

func _on_timer_timeout() -> void:
	if player_health < max_health and not is_dead and player_health>0:
		player_health+=1
	regen_timer.start(regen_time)

func increase_xp():
	player_xp += 1
	if player_xp == xp_per_lvl and player_level<5:
		player_level += 1
		max_health += 2
		player_health += 2
		player_xp = 0
		dash_cd -= 0.3
		speed += 20
		regen_time -= 1
		
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
