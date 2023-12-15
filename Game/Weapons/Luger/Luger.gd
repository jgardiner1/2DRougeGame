extends Node2D

@export var weapon_component : WeaponComponent
@onready var world = get_parent()

var can_pickup = true
var capacity:int = 1
