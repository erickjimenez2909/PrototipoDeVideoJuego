extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var isJumping = false
var jump_requested
var is_animating_jump = false

#VARIABLES PARA DASH
var last_input_time := 0.0
var double_tap_threshold := 0.3 # segundos
var last_direction := 0
var is_dashing := false
var dash_speed := SPEED * 2.5
var dash_duration := 0.4
var dash_timer := 0.0

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saltar si se presiona el botón y está en el suelo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AnimatedSprite2D.play("jumping")
		jump_requested = true
		is_animating_jump = true
		$JumpTimer.start()  # Inicia el temporizador

	# Actualizar estado de salto
	isJumping = not is_on_floor()

	# Movimiento horizontal
	# Movimiento normal
	var direction := Input.get_axis("ui_left", "ui_right")

	# Dash solo si se presiona una dirección
	if Input.is_action_just_pressed("ui_left"):
		handle_double_tap(-1)
	elif Input.is_action_just_pressed("ui_right"):
		handle_double_tap(1)

	# Movimiento horizontal con dash
	if is_dashing:
		velocity.x = direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animación
	decidirAnimacion(direction, isJumping)

	# Aplicar movimiento
	move_and_slide()

func decidirAnimacion(direction, isJumping):
	if is_animating_jump:
		if $AnimatedSprite2D.animation != "jumping":
			$AnimatedSprite2D.play("jumping")
		return
	if is_dashing:
		if $AnimatedSprite2D.animation != "dash":
			$AnimatedSprite2D.play("dash")
		return
	if direction != 0:
		$AnimatedSprite2D.play("walking")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		$AnimatedSprite2D.play("idle")


func _on_jump_timer_timeout() -> void:
	if jump_requested:
		velocity.y = JUMP_VELOCITY
		jump_requested = false

#Para activar dash solo cuando el jugador presione dos veces
func handle_double_tap(dir: int) -> void: 
	var current_time = Time.get_unix_time_from_system()
	if dir == last_direction and (current_time - last_input_time) < double_tap_threshold:
		is_dashing = true
		dash_timer = dash_duration
	else:
		last_input_time = current_time
		last_direction = dir


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "jumping":
		is_animating_jump = false
