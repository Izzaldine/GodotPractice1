extends Area2D

signal hit

@export var speed: float = 400.0

var screen_size := Vector2.ZERO
var is_dead := false


func _ready() -> void:
	add_to_group("player")
	screen_size = get_viewport_rect().size


func _process(delta: float) -> void:
	if is_dead:
		return

	screen_size = get_viewport_rect().size
	var velocity := Vector2.ZERO
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
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func die() -> void:
	if is_dead:
		return
	is_dead = true
	$AnimatedSprite2D.stop()
	hide()
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		die()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		die()


func start(pos: Vector2) -> void:
	position = pos
	is_dead = false
	show()
	$CollisionShape2D.set_deferred("disabled", false)
