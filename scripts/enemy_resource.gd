extends Resource
class_name enemy_resource

@export var movement_speed := 20.0
@export var enemy_health := 10
@export var damage := 1
@export var type: enemy_type
@export var enemy_level := 1
@export var attack_radius := 40

enum enemy_type  {SWORDSMAN, SPEARMAN}
