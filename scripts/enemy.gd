class_name Base_Enemy
extends CharacterBody2D

@export var resource: enemy_resource

var enemy_sprite: AnimatedSprite2D
var vision_area : CollisionPolygon2D
var patrol_timer : Timer
var player: Player

func _ready():
	vision_area = $Vision/VisionCone
	patrol_timer = $Patrol_Timer
	player = get_tree().get_nodes_in_group("Player").get(0)
	
	if resource.type == resource.enemy_type.SWORDSMAN:
		enemy_sprite = $Swordsman_Sprite
		$Spearman_Sprite.visible = false
	elif resource.type == enemy_resource.enemy_type.SPEARMAN:
		enemy_sprite = $Spearman_Sprite
		$Swordsman_Sprite.visible = false

func _physics_process(delta: float) -> void:
	var movement_speed = resource.movement_speed
	
	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * movement_speed
	if direction.x > 0:
		enemy_sprite.flip_h = true
	elif direction.x < 0: 
		enemy_sprite.flip_h = false
	
	move_and_collide(direction * movement_speed * delta)
	
func hurt_enemy(damage:int):
	resource.enemy_health -= damage
	if(resource.enemy_health <=0):
		queue_free()
