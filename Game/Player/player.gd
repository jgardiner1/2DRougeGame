extends CharacterBody2D

# Player Speed
const SPEED = 200.0

# Angles to track player direction
const MIN = -140
const MAX = -40
const MIDDLE = 90

# Nodes needed throughout this script
@onready var anim = get_node("AnimationPlayer")
@onready var InHandItem = get_node("InHandItem")
@onready var world = get_parent()

var collided_items = []

# Main loop executed every frame
func _physics_process(_delta):
	handle_movement()
	update_InHandItem_direction()
	handle_animations()
	move_and_slide()

	if Input.is_action_just_pressed("drop"):
		drop_item()
	if Input.is_action_just_pressed("pickup"):
		pickup_item()
	if Input.is_key_pressed(KEY_T):
		print_all_nodes()

# Returns angle from center of player to users mouse
func calc_aim_rotation() -> float:
	# calculate angle between InHandItem position and mouse cursor
	var angle = (get_local_mouse_position() - InHandItem.position).angle()
	# return angle
	return angle

# Handles player movement
func handle_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var hDirection = Input.get_axis("ui_left", "ui_right")
	var vDirection = Input.get_axis("ui_up", "ui_down")
	
	if hDirection or vDirection:
		velocity.x = hDirection * SPEED
		velocity.y = vDirection * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 25)
		velocity.y = move_toward(velocity.y, 0, 25)

# Determines if character should face left, right or backwards using CONST angles
func determine_face_direction(angle) -> int:
	# Backwards
	if angle > MIN and angle < MAX:
		return 0
	# Right
	elif angle > MAX and angle < MIDDLE:
		return 1
	else:
	# Left
		return -1

# Handles animationby checking if player is moving and what direction they're looking
func handle_animations() -> void:
	# Checks if movement vector is non zero (moving) and plays the running/idle animation
	if velocity.length_squared() > 0:
		match determine_face_direction(rad_to_deg(calc_aim_rotation())):
			-1, 1:
				anim.play("SideFaceRun")
			0:
				anim.play("BackFaceRun")
	else:
		match determine_face_direction(rad_to_deg(calc_aim_rotation())):
			-1, 1:
				anim.play("SideFaceIdle")
			0:
				anim.play("BackFaceIdle")

# Updates InHandItem direction and index
func update_InHandItem_direction() -> void:
	var angle = calc_aim_rotation()
	InHandItem.rotation = angle
	
	var direction = determine_face_direction(rad_to_deg(angle))
	# Gun index goes behind if the direction is looking back, otherwise it goes to top
	InHandItem.z_index = -1 if direction == 0 else 1
	# Sprite is horizontally flipped if direction is left
	$AnimatedSprite2D.flip_h = true if direction == -1 else false
	
	if InHandItem.get_child_count() != 0:
		InHandItem.get_child(0).get_node("ItemSprite").flip_v = true if direction == -1 else false

# Executed when drop item button pressed. Nothing happens if players hand is empty
func drop_item() -> void:
	# executes if something is in players hand
	if InHandItem.get_child_count() != 0:
		
		var ref_item = InHandItem.get_child(0)
		
		ref_item.reparent(world)
		print("Dropped: ", ref_item)
		ref_item.rotation = 0
		ref_item.get_node("ItemSprite").flip_v = false
		ref_item.get_node("ItemSprite").flip_h = false
	else:
		print("Nothing to drop")

func pickup_item() -> void:
	if get_node("InHandItem").get_child_count() != 0:
		return print("Hand full")
	if collided_items == null or collided_items.is_empty():
		return print("Nothing to pick up")
	if collided_items.size() == 1:
		print(collided_items[0])
		if collided_items[0].can_pickup:
			# pickup that item
			collided_items[0].reparent(InHandItem)
			collided_items.remove_at(0)
			InHandItem.get_child(0).position = Vector2.ZERO
			InHandItem.get_child(0).rotation = 0
		else:
			print("cant pickup")
	else:
		# decide which item to pickup
		print("more than 1 to choose from or cant pickup")
		var smallest = INF
		var smallest_index = 0
		
		for item in range(collided_items.size()):
			var dist = calculate_distance_between(collided_items[item].global_position, global_position)
			if dist < smallest:
				smallest = dist
				smallest_index = item
		
		collided_items[smallest_index].reparent(InHandItem)
		collided_items.remove_at(smallest_index)
		InHandItem.get_child(0).position = Vector2.ZERO

func calculate_distance_between(item1: Vector2, item2: Vector2) -> float:
	return sqrt(pow(item1.x - item2.x, 2) + pow(item1.y - item2.y, 2))

func print_all_nodes():
	print("In hand size: ", get_node("InHandItem").get_child_count())
	print("collided items size: ", collided_items.size())
	for item in collided_items:
		var distance = calculate_distance_between(item.position, position)
		print("distance between: ", item, " and player is ", distance)

func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	collided_items.append(area.get_parent())

func _on_area_2d_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	collided_items.remove_at(collided_items.find(area.get_parent()))