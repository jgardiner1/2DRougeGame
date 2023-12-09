extends CharacterBody2D

# Player Speed
const SPEED = 200.0

# Angles to track player direction
const MIN = -140
const MAX = -40
const MIDDLE = 90

# Nodes needed throughout this script
@onready var anim = get_node("AnimationPlayer")
@onready var LeftHandItem = get_node("LeftHandItem")
@onready var RightHandItem = get_node("RightHandItem")
@onready var TwoHandedItem = get_node("TwoHandedItem")
@onready var world = get_parent()
enum direction {BACKWARDS, RIGHT, LEFT}

var collided_items = []
var items_to_remove = []

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
	if Input.is_action_just_pressed("throw"):
		throw_item()
	remove_items()

# Returns angle from center of player to users mouse
func calc_aim_rotation() -> float:
	# calculate angle between InHandItem position and mouse cursor
	var angle = (get_local_mouse_position() - RightHandItem.position).angle()
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
func update_InHandItem_direction() -> void:
	var angle = calc_aim_rotation()
	
	# set items in hand to correct rotation
	LeftHandItem.rotation = angle
	RightHandItem.rotation = angle
	TwoHandedItem.rotation = angle
	
	# calculate which way we're facing
	var cur_dir = determine_face_direction(rad_to_deg(angle))
	
	# Gun index goes behind if the direction is looking back, otherwise it goes to top
	RightHandItem.z_index = -1 if cur_dir == 0 else 1
	LeftHandItem.z_index = -1 if cur_dir == 0 else 1
	TwoHandedItem.z_index = -1 if cur_dir == 0 else 1
	# Sprite is horizontally flipped if direction is left
	$AnimatedSprite2D.flip_h = true if cur_dir == 2 else false
	
	# Flip in hand sprites if we're looking left
	if RightHandItem.get_child_count() != 0:
		RightHandItem.get_child(0).get_node("ItemSprite").flip_v = true if cur_dir == 2 else false
	if LeftHandItem.get_child_count() != 0:
		LeftHandItem.get_child(0).get_node("ItemSprite").flip_v = true if cur_dir == 2 else false
	if TwoHandedItem.get_child_count() != 0:
		TwoHandedItem.get_child(0).get_node("ItemSprite").flip_v = true if cur_dir == 2 else false

# Executed when drop item button pressed. Nothing happens if players hand is empty
func drop_item() -> void:
	# executes if something is in players hand
	if TwoHandedItem.get_child_count() == 1:
		var ref_item = TwoHandedItem.get_child(0)
		
		drop(ref_item)
		
		return print("TwoHandedItem: ", ref_item, " dropped from ", TwoHandedItem)
	# executes 
	elif RightHandItem.get_child_count() == 1 and LeftHandItem.get_child_count() == 1:
		var ref_item = LeftHandItem.get_child(0)
		
		drop(ref_item)
		
		return print("OneHandedItem: ", ref_item, " dropped from ", LeftHandItem)
	elif RightHandItem.get_child_count() == 1 and LeftHandItem.get_child_count() == 0:
		var ref_item = RightHandItem.get_child(0)
		
		drop(ref_item)
		
		return print("OneHandedItem: ", ref_item, " dropped from ", RightHandItem)
	else:
		return print("Nothing to drop")

# reparent item from hand to world
func drop(ref_item) -> void:
	ref_item.reparent(world)
	ref_item.rotation = 0
	ref_item.get_node("ItemSprite").flip_v = false
	ref_item.get_node("ItemSprite").flip_h = false

# logic for picking up 1 and 2 handed items
func pickup_item() -> void:
	# check for both hands full
	if (RightHandItem.get_child_count() == 1 and LeftHandItem.get_child_count() == 1) or TwoHandedItem.get_child_count() == 1:
		return print("Both hands full")
		
	# Check if no items nearby
	if collided_items == null or collided_items.is_empty():
		return print("Nothing to pick up")
		
	# Check if only 1 item nearby and it can be picked up
	if collided_items.size() == 1 and collided_items[0].can_pickup == true:
		if collided_items[0].two_handed == true and LeftHandItem.get_child_count() == 0 and RightHandItem.get_child_count() == 0:
			collided_items[0].reparent(TwoHandedItem)

			items_to_remove.append(collided_items[0])
			reset_item(TwoHandedItem.get_child(0))
			return print("TwoHandedItem: ", TwoHandedItem.get_child(0), " Picked up with ", TwoHandedItem)
		if collided_items[0].two_handed == false:
			# check if right hand free
			if RightHandItem.get_child_count() == 0:
				# pickup that item
				collided_items[0].reparent(RightHandItem)

				items_to_remove.append(collided_items[0])
				reset_item(RightHandItem.get_child(0))
				return print("OneHandedItem: ", RightHandItem.get_child(0), " Picked up with ", RightHandItem)
			# check if left hand free
			elif LeftHandItem.get_child_count() == 0:
				# pickup that item
				collided_items[0].reparent(LeftHandItem)

				items_to_remove.append(collided_items[0])
				reset_item(LeftHandItem.get_child(0))
				return print("OneHandedItem: ", LeftHandItem.get_child(0), " Picked up with ", LeftHandItem)
			else:
				return print("Not enough hands")
		else:
			return print("Item cannot be picked up")
	else:
		# Check for if there is more than one to pick up
		collided_items.sort_custom(sort_by_distance)
		
		for item in collided_items:
			if collided_items[0].two_handed:
				if LeftHandItem.get_child_count() == 0 and RightHandItem.get_child_count() == 0:
					collided_items[0].reparent(TwoHandedItem)

					items_to_remove.append(item)
					reset_item(TwoHandedItem.get_child(0))
					return print("TwoHandedItem: ", TwoHandedItem.get_child(0), " Picked up with ", TwoHandedItem)
				else:
					return print("Not enough hands")
			elif not collided_items[0].two_handed:
				# check if right hand free
				if RightHandItem.get_child_count() == 0:
					# pickup that item
					collided_items[0].reparent(RightHandItem)

					items_to_remove.append(item)
					reset_item(RightHandItem.get_child(0))
					return print("OneHandedItem: ", RightHandItem.get_child(0), " Picked up with ", RightHandItem)
				# check if left hand free
				elif LeftHandItem.get_child_count() == 0:
					# pickup that item
					collided_items[0].reparent(LeftHandItem)
					print("removing item from collided items. size before remove is ", collided_items.size())
					items_to_remove.append(item)
					print("item removed: current size = ", collided_items.size())
					reset_item(LeftHandItem.get_child(0))
					return print("OneHandedItem: ", LeftHandItem.get_child(0), " Picked up with ", LeftHandItem)
				else:
					return print("Not enough hands")

# resets items rotation and position after being picked up
func reset_item(item) -> void:
	item.position = Vector2.ZERO
	item.rotation = 0

func throw_item() -> void:
	if LeftHandItem.get_child_count() == 0 and RightHandItem.get_child_count() == 0 and TwoHandedItem.get_child_count() == 0:
		return print("NOTHING TO THROW")
		
	if TwoHandedItem.get_child_count() == 1:
		var item = TwoHandedItem.get_child(0)
		items_to_remove.append(item)
		item.reparent(world)
		var throw_direction = (get_global_mouse_position() - position).normalized()
		item.linear_velocity = throw_direction * 1500
		item.linear_damp = 7
		item.angular_velocity = randf_range(-5, 5)
		item.angular_damp = 1
		return
	
	if RightHandItem.get_child_count() == 1:
		var item = RightHandItem.get_child(0)
		items_to_remove.append(item)
		item.reparent(world)
		var throw_direction = (get_global_mouse_position() - position).normalized()
		item.linear_velocity = throw_direction * 1500
		item.linear_damp = 7
		item.angular_velocity = randf_range(-5, 5)
		item.angular_damp = 1
		if LeftHandItem.get_child_count() == 1:
			items_to_remove.append(LeftHandItem.get_child(0))
			LeftHandItem.get_child(0).reparent(RightHandItem)
			reset_item(RightHandItem.get_child(0))

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
	print("Items in player radius: ", collided_items.size())
	for item in collided_items:
		print(item)
	#print("\n\n")
	
func remove_items():
	if not items_to_remove.is_empty():
		for item in items_to_remove:
			collided_items.remove_at(collided_items.find(item))
		items_to_remove.clear()
		return

func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	#var master_parent = area.get_parent().get_parent()
	#if master_parent != LeftHandItem and master_parent != RightHandItem and master_parent != TwoHandedItem:
	
	collided_items.append(area.get_parent())

func _on_area_2d_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	for item in collided_items:
		if item == area.get_parent():
			items_to_remove.append(item)
