extends Sprite2D

signal health_depleted ## signal to be emitted when health reaches 0
signal health_changed(old,new) ## signal to get the old and new health values
var health: int = 100 ## health of the player
var speed: int = 400 ## speed of the sprite
var angular_speed: float = PI ## angular speed of the sprite


func _ready():
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)


func _process(delta: float) -> void:
	rotation += angular_speed * delta
	var velocity = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta

func take_damage(amount:int) -> void:
	health -= amount
	health_changed.emit(health+amount, health)
	if health <= 0:
		health = 0
		health_depleted.emit()


func _on_button_pressed() -> void:
	set_process(not is_processing())


func _on_timer_timeout():
	visible = not visible
