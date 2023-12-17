extends Node2D
class_name WeaponComponent

@export var bullet_damage : float
@export var bullet_speed : float
@export var knockback_force : float
@export var magazine_size : int
@export var ammo_reserve : int
@export var reload_time : float
@export var fire_rate : float
@export var bullet_spread : float

var cur_ammo : int
var reload_total : int

@onready var reload_timer = $ReloadTimer
@onready var firerate_timer = $FirerateTimer

const bullet = preload("res://Weapons/Projectiles/DefaultBullet.tscn")

func _ready():
	reload_timer.set_wait_time(reload_time)
	firerate_timer.set_wait_time(60 / fire_rate)
	print(firerate_timer.get_wait_time())
	cur_ammo = magazine_size
	
func shoot():
	if !firerate_timer.is_stopped() or !reload_timer.is_stopped() or cur_ammo == 0:
		#print("Cant shoot so quick")
		return
		
	var bullet_instance = bullet.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	
	# set bullet start position to WeaponComponent(barrel) position
	bullet_instance.position = global_position
	# set bullet direction to wherever gun is facing
	bullet_instance.velocity = global_transform.x
	bullet_instance.velocity += global_transform.y * randf_range(-bullet_spread, bullet_spread)

	# set bullet speed
	bullet_instance.speed = bullet_speed
	# set bullet rotation
	bullet_instance.rotation = (get_global_mouse_position() - bullet_instance.position).angle()
	
	cur_ammo -= 1
	firerate_timer.start()
	randomize()
	
func shotgun_shoot():
	if !firerate_timer.is_stopped() or !reload_timer.is_stopped() or cur_ammo == 0:
		#print("Cant shoot so quick")
		return

	for x in range(8):
		var bullet_instance = bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)
		
		# set bullet start position to WeaponComponent(barrel) position
		bullet_instance.position = global_position
		# set bullet direction to wherever gun is facing
		bullet_instance.velocity = global_transform.x
		bullet_instance.velocity += global_transform.y * randf_range(-bullet_spread, bullet_spread)

		# set bullet speed
		bullet_instance.speed = bullet_speed
		# set bullet rotation
		bullet_instance.rotation = (get_global_mouse_position() - bullet_instance.position).angle()
		randomize()
	
	firerate_timer.start()

func reload():
	if ammo_reserve < 1:
		print("no ammo left for this weapon")
		return
	if cur_ammo == magazine_size:
		print("no need to reload")
		return
		
	var ammo_needed :=  magazine_size - cur_ammo
	
	reload_total = ammo_needed if ammo_reserve >= ammo_needed else ammo_reserve 
	reload_timer.start()
	ammo_reserve -= reload_total
	
	print("RELOADING\nAmmo needed: ", ammo_needed, "\nReload Total: ", reload_total, "\nAmmo Reserve: ", ammo_reserve)

func _on_reload_timer_timeout():
	print("reloaded")
	cur_ammo += reload_total
	reload_total = 0
