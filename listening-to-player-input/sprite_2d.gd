extends Sprite2D

#var radius: float = 20 ## radius of the circle
var speed: int = 400 ## speed of the sprite
var angular_speed: float = PI #speed / radius ## angular speed of the sprite
#var screen_size: Vector2 ## screen size of the viewport

#func _ready() -> void:
	#screen_size = get_viewport_rect().size
	#global_position = screen_size / 2
	#global_position.x = global_position.x / 2
	
func _process(delta: float) -> void:
	var direction := 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1
	rotation += angular_speed * direction * delta
	var velocity := Vector2.ZERO
	var move := 0
	if Input.is_action_pressed("ui_up"):
		move = 1
	if Input.is_action_pressed("ui_down"):
		move = -1
	velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * move * delta
