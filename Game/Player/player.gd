extends CharacterBody2D

# Player Speed
@export var WALK_SPEED:float = 200.0
@export var RUN_SPEED:float = 350.0
var SPEED

# Angles to track player direction
const MIN := -140
const MAX := -40
const MIDDLE := 90

# Nodes needed throughout this script
@onready var anim = get_node("AnimationPlayer")
@onready var hands = get_node("Hands")
@onready var world = get_parent()
enum direction {BACKWARDS, RIGHT, LEFT}

var items_within_reach: Array
var items_to_remove: Array

var max_hand_capacity:int = 2
var cur_hand_capacity:int = 0

# Main loop executed every frame
func _physics_process(_delta):
	handle_movement()
	update_item_in_hand_direction_and_position()
	handle_animations()
	move_and_slide()

	if Input.is_action_just_pressed("drop"):
		drop_item()
	if Input.is_action_just_pressed("pickup"):
		pickup_item()
	if Input.is_key_pressed(KEY_T):
		print_all_nodes()
	if Input.is_action_just_pressed("throw"):
		throw_item()
	remove_items()

# Returns angle from center of player to users mouse
func calc_aim_rotation() -> float:
	# calculate angle between InHandItem position and mouse cursor
	var angle = (get_global_mouse_position() - position).angle()
	# return angle
	return angle

# Handles player movement
func handle_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var hDirection = Input.get_axis("ui_left", "ui_right")
	var vDirection = Input.get_axis("ui_up", "ui_down")
	
	SPEED = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
	
	if hDirection or vDirection:
		velocity.x = hDirection * SPEED
		velocity.y = vDirection * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 25)
		velocity.y = move_toward(velocity.y, 0, 25)

# Determines if character should face left, right or backwards using CONST angles
func determine_face_direction(angle) -> direction:
	# Backwards
	if angle > MIN and angle < MAX:
		return direction.BACKWARDS
	# Right
	elif angle > MAX and angle < MIDDLE:
		return direction.RIGHT
	else:
	# Left
		return direction.LEFT

# Handles animationby checking if player is moving and what direction they're looking
func handle_animations() -> void:
	# Checks if movement vector is non zero (moving) and plays the running/idle animation
	if velocity.length_squared() > 0:
		match determine_face_direction(rad_to_deg(calc_aim_rotation())):
			direction.LEFT, direction.RIGHT:
				anim.play("SideFaceRun")
			direction.BACKWARDS:
				anim.play("BackFaceRun")
	else:
		match determine_face_direction(rad_to_deg(calc_aim_rotation())):
			direction.LEFT, direction.RIGHT:
				anim.play("SideFaceIdle")
			direction.BACKWARDS:
				anim.play("BackFaceIdle")

# Updates InHandItem direction and index
func update_item_in_hand_direction_and_position() -> void:
	var angle = calc_aim_rotation()
	
	# set items in hand to correct rotation
	hands.rotation = angle
	
	# calculate which way we're facing
	var cur_dir = determine_face_direction(rad_to_deg(angle))
	
	# Gun index goes behind if the direction is looking back, otherwise it goes to top
	hands.z_index = -1 if cur_dir == 0 else 1
	# Sprite is horizontally flipped if direction is left
	$AnimatedSprite2D.flip_h = true if cur_dir == 2 else false
	
	# Flip sprites in hand if we're looking left
	for item in hands.get_children():
		item.get_node("ItemSprite").flip_v = true if cur_dir == 2 else false

# Executed when drop item button pressed. Nothing happens if players hand is empty
func drop_item() -> void:
	if hands.get_child_count() > 0:
		var ref_item = hands.get_child(0)
		ref_item.reparent(world)
		items_within_reach.append(ref_item)
		ref_item.rotation = 0
		ref_item.get_node("ItemSprite").flip_v = false
		ref_item.get_node("ItemSprite").flip_h = false
		cur_hand_capacity -= ref_item.capacity
		return print(ref_item, " dropped. Capacity left: ", max_hand_capacity - cur_hand_capacity)
	else:
		return print("No item to drop")

# logic for picking up 1 and 2 handed items
func pickup_item() -> void:
	# Handles for if players hands full or nothing within reach
	if cur_hand_capacity == max_hand_capacity:
		return print("Cannot pick up item: hands full")
	if items_within_reach == null or items_within_reach.is_empty():
		return print("No item nearby to pickup")
	
	# Re-orders items in vicinity by closest distance to player
	if items_within_reach.size() > 1:
		items_within_reach.sort_custom(sort_by_distance)
	
	# For each item we try and pick up
	for item in items_within_reach:
		if cur_hand_capacity + item.capacity > max_hand_capacity:
			print(item, " cannot be picked up. Not enough space in hands")
		else:
			item.reparent(hands)
			item.position = get_parent().globalposition
			item.rotation = 0
			cur_hand_capacity += item.capacity
			return print("Item", item, " Picked up. Capacity left: ", max_hand_capacity - cur_hand_capacity)

func throw_item() -> void:
	if hands.get_child_count() > 0:
		var ref_item = hands.get_child(0)
		ref_item.reparent(world)
		items_within_reach.append(ref_item)
		var throw_direction = (get_global_mouse_position() - position).normalized()
		ref_item.linear_velocity = throw_direction * 1500
		ref_item.linear_damp = 7
		ref_item.angular_velocity = randf_range(-5, 5)
		ref_item.angular_damp = 1
		cur_hand_capacity -= ref_item.capacity
		return print(ref_item, " thrown. Capacity left: ", max_hand_capacity - cur_hand_capacity)
	else:
		return print("No item to throw")

# calculates distance between 2 items
func calculate_distance_between(item1: Vector2, item2: Vector2) -> float:
	return sqrt(pow(item1.x - item2.x, 2) + pow(item1.y - item2.y, 2))

# sorting algorithm to return list by closest distance
func sort_by_distance(a, b):
	if calculate_distance_between(a.position, position) < calculate_distance_between(b.position, position):
		return true
	return false

func print_all_nodes():
	print("DEBUG")
	#print("Left Hand: ", LeftHandItem.get_child(0))
	#print("Right Hand: ", RightHandItem.get_child(0))
	#print("Two Hand: ", TwoHandedItem.get_child(0))
	#print("\n")
	#print("Items in player radius: ", collided_items.size())
	#for item in collided_items:
		#print(item)
	#print("\n\n")
	
func remove_items():
	for item in items_to_remove:
		items_within_reach.erase(item)
	items_to_remove.clear()

func _on_pickup_radius_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.get_parent() not in items_within_reach and not area.find_parent("Player"):
		items_within_reach.append(area.get_parent())

func _on_pickup_radius_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.get_parent() not in items_to_remove:
		items_to_remove.append(area.get_parent())
