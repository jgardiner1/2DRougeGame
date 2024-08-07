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
@export var max_recoil : float

const bullet = preload("res://Weapons/Projectiles/DefaultBullet.tscn")

var cur_ammo : int
var reload_total : int
var current_recoil := 0.0

@onready var reload_timer = $ReloadTimer
@onready var firerate_timer = $FirerateTimer

@onready var gun_sprite = get_parent().get_node("ItemSprite")
@onready var gun_sprite_vector = gun_sprite.position

func _ready():
	reload_timer.set_wait_time(reload_time)
	firerate_timer.set_wait_time(60 / fire_rate)
	#print(get_parent(), firerate_timer.get_wait_time())
	cur_ammo = magazine_size

func _process(_delta):
	if not Input.is_action_pressed("shoot"):
		current_recoil = clamp(current_recoil - (max_recoil * 0.3), 0.0, max_recoil)


func shoot() -> bool:
	if !firerate_timer.is_stopped() or !reload_timer.is_stopped() or cur_ammo == 0:
		#print("Cant shoot so quick")
		return false
	
	var tween = get_tree().create_tween()
	tween.tween_property(gun_sprite, "position", Vector2(gun_sprite.position.x - 5, gun_sprite.position.y), 0.05)
		
	var bullet_instance = bullet.instantiate()
	
	get_tree().current_scene.add_child(bullet_instance)
	
	# set bullet start position to WeaponComponent(barrel) position
	bullet_instance.position = global_position
	# set bullet direction to wherever gun is facing
	bullet_instance.velocity = global_transform.x
	bullet_instance.velocity += global_transform.y * calc_recoil()

	# set bullet speed
	bullet_instance.speed = bullet_speed
	# set bullet rotation
	bullet_instance.rotation = (get_global_mouse_position() - bullet_instance.position).angle()
	bullet_instance.damage = bullet_damage
	
	cur_ammo -= 1
	tween.tween_property(gun_sprite, "position", gun_sprite_vector, 0.05)
	firerate_timer.start()
	randomize()
	return true
	
func calc_recoil() -> float:
	current_recoil = clamp(current_recoil + (max_recoil * 0.05), 0.0, max_recoil)
	var recoil_degree_max = current_recoil * 0.5
	return deg_to_rad(randf_range(-recoil_degree_max, recoil_degree_max))

func shotgun_shoot():
	if !firerate_timer.is_stopped() or !reload_timer.is_stopped() or cur_ammo == 0:
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
		bullet_instance.damage = bullet_damage
		randomize()
	
	cur_ammo -= 1
	firerate_timer.start()

func reload():
	if ammo_reserve < 1:
		print("no ammo left for this weapon")
		return
	if cur_ammo == magazine_size:
		print("no need to reload")
		return
	if not reload_timer.is_stopped():
		print("Currently Reloading")
		return
		
	var ammo_needed :=  magazine_size - cur_ammo
	
	reload_total = ammo_needed if ammo_reserve >= ammo_needed else ammo_reserve 
	reload_timer.start()
	
	print("RELOADING\nCurrent Ammo: ", cur_ammo, "\nAmmo needed: ", ammo_needed, "\nReload Total: ", reload_total, "\nAmmo Reserve: ", ammo_reserve)

func cancel_reload():
	pass

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE and not reload_timer.is_stopped():
		print("cancelling reload")
		reload_timer.stop()

func _on_reload_timer_timeout():
	print("reloaded")
	cur_ammo += reload_total
	ammo_reserve -= reload_total
	reload_total = 0
