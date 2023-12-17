extends RigidBody2D

@export var weapon_component : WeaponComponent

var can_pickup = true
var capacity:int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func shoot():
	print("SHOOTING")
	if weapon_component:
		print("GUN STATS")
		print("bullet_damage: ", weapon_component.bullet_damage)
		print("fire_rate: ", weapon_component.fire_rate)
		print("knockback_force: ", weapon_component.knockback_force)
		print("magazine_size: ", weapon_component.magazine_size)
		print("max_ammo: ", weapon_component.max_ammo)
