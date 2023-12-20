extends RigidBody2D

var velocity = Vector2.ZERO
var speed : float
var damage: float
var collision_info = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	collision_info = move_and_collide(velocity.normalized() * delta * speed)
	if collision_info != null:
		queue_free()
		print("done ", damage, " to ", collision_info.get_collider())
