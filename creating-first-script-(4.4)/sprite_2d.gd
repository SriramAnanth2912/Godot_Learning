extends Sprite2D

var radius: float = 200 ## radius of the circle
var speed: int = 200 ## speed of the sprite
var angular_speed: float = speed / radius ## angular speed of the sprite
var screen_size: Vector2 ## screen size of the viewport

#func _ready() -> void:
	#screen_size = get_viewport_rect().size
	#global_position = screen_size / 2
	#global_position.x = global_position.x / 2
	
func _process(delta: float) -> void:
	rotation += angular_speed * delta
	var velocity: Vector2 = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta
