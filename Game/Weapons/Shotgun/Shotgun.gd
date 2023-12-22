extends RigidBody2D

@export var weapon_component : WeaponComponent

var can_pickup = true
var capacity:int = 2

func _process(_delta):
	if find_parent("Player"):
		if Input.is_action_pressed("shoot"):
			weapon_component.shotgun_shoot()
		if Input.is_action_just_pressed("reload"):
			weapon_component.reload()
