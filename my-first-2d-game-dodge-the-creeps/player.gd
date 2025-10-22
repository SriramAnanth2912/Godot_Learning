extends Area2D

signal hit ## our player emit (send out) when it collides with an enemy.
@export var speed: int = 400 ## How fast the player will move (pixels/sec).
var screen_size: Vector2 ## Size of the game window.
var player_size: Vector2 ## player size
# Called when the node enters the scene tree for the first time.
var touch_is_down = false ## to check whether is touching the screen
var touch_target ## new position for the player to go to

func _input(event):
	if event is InputEventScreenTouch: ## for touch screen users
		if event.pressed:
			touch_is_down = true
			touch_target = event.position
		elif event.released:
			touch_is_down = false
	elif event is InputEventScreenDrag:
		touch_target = event.position

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if touch_is_down and position.distance_to(touch_target) > 5:
		## for touch screen users
		velocity = (touch_target - position)
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play() # same as get_node("AnimatedSprite2D").play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	player_size = $CollisionShape2D.shape.get_rect().size
	position = position.clamp(Vector2.ZERO + player_size/2, screen_size - player_size/2)
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func _on_body_entered(_body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
