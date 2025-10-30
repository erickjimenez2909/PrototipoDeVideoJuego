extends CharacterBody2D

# Constantes
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DOUBLE_TAP_THRESHOLD = 0.3
const DASH_DURATION = 0.4
const DASH_MULTIPLIER = 2.5
const RUN_MULTIPLIER = 1.5

# Estado
var isJumping = false
var jump_requested = false
var is_animating_jump = false
var is_dashing = false
var is_running = false

# Dash
var last_input_time := 0.0
var last_direction := 0
var dash_timer := 0.0

# Velocidades
var dash_speed := SPEED * DASH_MULTIPLIER
var run_speed := SPEED * RUN_MULTIPLIER

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	check_jump()
	isJumping = not is_on_floor()

	var direction := get_movement_direction()
	check_dash_input()
	check_running_state()
	apply_horizontal_movement(direction, delta)
	update_animation(direction)

	move_and_slide()

func get_movement_direction() -> float:
	return Input.get_axis("ui_left", "ui_right")

func check_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AnimatedSprite2D.play("jumping")
		jump_requested = true
		is_animating_jump = true
		$JumpTimer.start()

func check_dash_input() -> void:
	if Input.is_action_just_pressed("ui_left"):
		handle_double_tap(-1)
	elif Input.is_action_just_pressed("ui_right"):
		handle_double_tap(1)

func check_running_state() -> void:
	is_running = (
		(Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"))
		and Input.is_action_pressed("shift")
	)

func apply_horizontal_movement(direction: float, delta: float) -> void:
	if is_dashing:
		velocity.x = direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		var speed = run_speed if is_running else SPEED
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func update_animation(direction: float) -> void:
	if is_animating_jump:
		if $AnimatedSprite2D.animation != "jumping":
			$AnimatedSprite2D.play("jumping")
		return

	if is_running:
		if $AnimatedSprite2D.animation != "running":
			$AnimatedSprite2D.play("running")
		$AnimatedSprite2D.flip_h = direction < 0
		return

	if is_dashing:
		if $AnimatedSprite2D.animation != "dash":
			$AnimatedSprite2D.play("dash")
		$AnimatedSprite2D.flip_h = direction < 0
		return

	if direction != 0:
		$AnimatedSprite2D.play("walking")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		$AnimatedSprite2D.play("idle")

func handle_double_tap(dir: int) -> void:
	var current_time = Time.get_unix_time_from_system()
	if dir == last_direction and (current_time - last_input_time) < DOUBLE_TAP_THRESHOLD:
		is_dashing = true
		dash_timer = DASH_DURATION
	else:
		last_input_time = current_time
		last_direction = dir

func _on_jump_timer_timeout() -> void:
	if jump_requested:
		velocity.y = JUMP_VELOCITY
		jump_requested = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "jumping":
		is_animating_jump = false

func _input(event):
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		if not event.pressed:
			is_running = false
