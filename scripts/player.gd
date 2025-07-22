extends CharacterBody2D 

@export var speed := 200
@export var dash_range := 50
@export var dash_cd := 3.0
@export var player_health := 10.0
@export var selected_weapon = WEAPONS.AXE

@onready var dash_timer := $"UI Transform/Dash/Dash Timer"
@onready var dash_pb := $"UI Transform/Dash/Dash PB"
@onready var animation_tree := $AnimationTree
@onready var health_pb := $"UI Transform/Health/Health PB"
@onready var died_text := $"UI Transform/DiedText"
@onready var player_node := $AnimatedSprite2D
@onready var weapon_hitbox := $"Hitbox Area"

# Weapon enum
enum WEAPONS {AXE, HAMMER}

var last_known_direction := Vector2.ZERO
var is_dashing := false

# Movement booleans
var is_axe_idle := true
var is_axe_moving := false
var is_axe_lattack := false
var is_axe_rattack := false

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

func _physics_process(_delta: float) -> void:
	process_movement_input()
	process_movement_animation()
	process_action_input()
	
	update_dash_pb()
	update_health_pb()

func process_movement_input():
	var direction = Input.get_vector("move_left","move_right","move_forward","move_back")
	direction = direction.normalized()
		
	if direction.x > 0 :
		player_node.flip_h = false
		weapon_hitbox.position.x = 33
	elif direction.x < 0:
		player_node.flip_h = true
		weapon_hitbox.position.x = -33
	else:
		if direction.y !=0:
			weapon_hitbox.position.x = 0
		else:
			weapon_hitbox.position.x = 0
	
	if direction != Vector2.ZERO:
		animation_tree["parameters/Axe_Idle/blend_position"] = direction
		animation_tree["parameters/Axe_Light_Attack/blend_position"] = direction
		animation_tree["parameters/Axe_walk/blend_position"] = direction
	
	velocity = direction * speed * (dash_range if is_dashing else 1)
	is_dashing = false
	

	move_and_slide()
	
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
		if dash_timer.is_stopped():
			is_dashing = true
			dash_timer.start()
	
func update_dash_pb():
	if not dash_timer.is_stopped():
		dash_pb.value = dash_timer.wait_time - dash_timer.time_left
		
func update_health_pb():
	health_pb.value = player_health
	#player_health -= 0.01
	if(player_health<=0):
		died_text.visible = true
		get_tree().paused = true

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

func switch_to_axe_idle() -> void:
	is_axe_idle = true
	is_axe_moving = false
	
func switch_to_axe_moving() -> void:
	is_axe_idle = false
	is_axe_moving = true
	
func switch_to_axe_lattack() -> void:
	is_axe_lattack  = true
	
func switch_to_axe_rattack() -> void:
	is_axe_rattack  = true
