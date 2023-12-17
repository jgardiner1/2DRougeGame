extends RigidBody2D

var velocity = Vector2.ZERO
var speed = 700
var collision_info = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	collision_info = move_and_collide(velocity.normalized() * delta * speed)
	if collision_info != null:
		queue_free()
