extends CharacterBody2D 

@export var speed := 400
@export var dash_range := 50
@export var dash_cd := 3.0
@export var player_health := 10.0

@onready var dash_timer = $"UI Transform/Dash/Dash Timer"
@onready var dash_pb = $"UI Transform/Dash/Dash PB"
@onready var animation_player = $AnimatedSprite2D
@onready var health_pb = $"UI Transform/Health/Health PB"
@onready var died_text = $"UI Transform/DiedText"

var last_known_direction := Vector2.ZERO
var is_dashing := false

func _ready() -> void:
	dash_pb.min_value = 0
	dash_timer.wait_time = dash_cd
	dash_pb.max_value = dash_cd
	dash_pb.value = dash_cd
	health_pb.value = player_health
	health_pb.max_value = player_health
	died_text.visible = false

func _physics_process(delta: float) -> void:
	process_movement_input(delta)
	process_action_input()
	update_dash_pb()
	update_health_pb()

func process_movement_input(delta: float):
	
	var direction = Input.get_vector("move_left","move_right","move_forward","move_back")
	direction = direction.normalized()
	
	velocity = direction * speed * (dash_range if is_dashing else 1)
	is_dashing = false

	process_animation(direction)
	move_and_slide()
	
func process_action_input():
	if Input.is_action_just_pressed("primary_attack"):
		print("WHACK!!!")
	if Input.is_action_just_pressed("secondary_attack"):
		print("WHAAAASH!!!")
	if Input.is_action_just_pressed("dash"):
		if dash_timer.is_stopped():
			is_dashing = true
			dash_timer.start()
	
func update_dash_pb():
	if not dash_timer.is_stopped():
		dash_pb.value = dash_timer.wait_time - dash_timer.time_left
		
func update_health_pb():
	health_pb.value = player_health
	player_health -= 0.01
	if(player_health<=0):
		died_text.visible = true
		get_tree().paused = true
	print(player_health)

func process_animation(direction: Vector2):
	var base_animation: String
	var current_direction: Vector2
	
	if direction.y != 0 or direction.x !=0:
		current_direction = direction
		base_animation = "walk"
		last_known_direction = direction
	else:
		current_direction = last_known_direction
		base_animation = "idle"
	
	if current_direction.y < 0:
		animation_player.play(base_animation + "_up")
	elif current_direction.y > 0:
		animation_player.play(base_animation + "_down")
	else:
		if current_direction.x > 0:
			animation_player.play(base_animation + "_right")	
		elif current_direction.x < 0:
			animation_player.play(base_animation + "_left")
		else:
			if last_known_direction.y<0:
				animation_player.play(base_animation + "_up")
			elif last_known_direction.y>0:
				animation_player.play(base_animation + "_down")
			elif last_known_direction.x>=0:
				animation_player.play(base_animation + "_right")
			else:
				animation_player.play(base_animation + "_left")
