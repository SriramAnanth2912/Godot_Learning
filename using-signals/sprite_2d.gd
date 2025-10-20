extends Sprite2D

var speed: int = 400 ## speed of the sprite
var angular_speed: float = PI ## angular speed of the sprite
	
func _process(delta: float) -> void:
	rotation += angular_speed * delta
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta


func _on_button_pressed() -> void:
	set_process(not is_processing())
