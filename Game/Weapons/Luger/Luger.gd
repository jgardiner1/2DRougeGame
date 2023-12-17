extends Node2D

@export var weapon_component : WeaponComponent

var can_pickup = true
var capacity:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	if find_parent("Player"):
		if Input.is_action_pressed("shoot"):
			weapon_component.shoot()
		if Input.is_action_just_pressed("reload"):
			weapon_component.reload()
