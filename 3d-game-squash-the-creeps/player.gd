extends CharacterBody3D

# Emitted when the player was hit by a mob.
signal hit

# How fast the player moves in meters per second.
@export var speed: float = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration: float = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse: int = 20
# Vertical impulse applied to the character upon bouncing over a mob in
# meters per second.
@export var bounce_impulse: float = 16

@onready var spawn_path: Path3D = $"../SpawnPath" # can also just use $"../SpawnPath"

var path_bounds: Vector3
var target_velocity: Vector3= Vector3.ZERO

func _ready() -> void:
	# Calculate path bounds
	var curve: Curve3D = spawn_path.curve
	var aabb: AABB = AABB()  # Creates empty bounding box
	
	# Expand box to include all path points
	for i: int in curve.point_count:
		aabb = aabb.expand(curve.get_point_position(i))

	path_bounds = aabb.size
	
	
func _physics_process(delta: float) -> void:
	# We create a local variable to store the input direction.
	var direction: Vector3 = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		
	# Iterate through all collisions that occurred this frame
	for index: int in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision: KinematicCollision3D = get_slide_collision(index)

		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group("mob").
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob: Object = collision.get_collider()
			# we check that we are hitting it from above.
			#print(Vector3.UP.dot(collision.get_normal()))
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break
				
	# Moving the Character
	velocity = target_velocity
	
	position.x = clamp(position.x, -path_bounds.x/2, path_bounds.x/2)
	position.z = clamp(position.z, -path_bounds.z/2, path_bounds.z/2)
	move_and_slide()


func die() -> void:
	hit.emit()
	queue_free()


func _on_mob_detector_body_entered(_body: Node3D) -> void:
	print_debug("hit!")
	die()
