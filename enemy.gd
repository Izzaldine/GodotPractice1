extends CharacterBody2D

enum State {
	WANDER,
	CHASE,
}

@export var wander_speed: float = 130.0
@export var chase_speed: float = 240.0
@export var steering: float = 6.0
@export var detection_range: float = 550.0
@export var wander_interval: float = 1.8

var state: State = State.WANDER
var target: Node2D = null
var wander_direction: Vector2 = Vector2.RIGHT
var wander_timer: float = 0.0


func _ready() -> void:
	add_to_group("enemies")
	randomize()
	_pick_random_animation()
	_pick_new_wander_direction()
	target = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D

	var desired_velocity := Vector2.ZERO

	if _can_chase_target():
		state = State.CHASE
		var to_target := target.global_position - global_position
		if to_target.length_squared() > 1.0:
			desired_velocity = to_target.normalized() * chase_speed
	else:
		state = State.WANDER
		_update_wander(delta)
		desired_velocity = wander_direction * wander_speed

	velocity = velocity.lerp(desired_velocity, clampf(steering * delta, 0.0, 1.0))
	move_and_slide()
	_keep_within_screen()
	_update_visuals(delta)


func _can_chase_target() -> bool:
	if not is_instance_valid(target) or not target.visible:
		return false
	if "is_dead" in target and target.is_dead:
		return false
	return global_position.distance_to(target.global_position) <= detection_range


func _update_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_wander_direction()


func _pick_new_wander_direction() -> void:
	var angle := randf_range(0.0, TAU)
	wander_direction = Vector2.from_angle(angle)
	wander_timer = randf_range(wander_interval * 0.6, wander_interval * 1.4)


func _keep_within_screen() -> void:
	var screen_size := get_viewport_rect().size
	var margin := 32.0
	if global_position.x < margin:
		global_position.x = margin
		wander_direction.x = absf(wander_direction.x)
	elif global_position.x > screen_size.x - margin:
		global_position.x = screen_size.x - margin
		wander_direction.x = -absf(wander_direction.x)

	if global_position.y < margin:
		global_position.y = margin
		wander_direction.y = absf(wander_direction.y)
	elif global_position.y > screen_size.y - margin:
		global_position.y = screen_size.y - margin
		wander_direction.y = -absf(wander_direction.y)


func _pick_random_animation() -> void:
	var sprite := $AnimatedSprite2D as AnimatedSprite2D
	var anim_names: PackedStringArray = sprite.sprite_frames.get_animation_names()
	if anim_names.size() > 0:
		var chosen: String = anim_names[randi() % anim_names.size()]
		sprite.play(chosen)


func _update_visuals(delta: float) -> void:
	if velocity.length_squared() > 4.0:
		rotation = lerp_angle(rotation, velocity.angle(), clampf(10.0 * delta, 0.0, 1.0))
		$AnimatedSprite2D.flip_v = velocity.x < 0.0
