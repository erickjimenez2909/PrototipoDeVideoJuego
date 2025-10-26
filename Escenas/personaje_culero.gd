extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var isJumping = false

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saltar si se presiona el botón y está en el suelo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Actualizar estado de salto
	isJumping = not is_on_floor()

	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animación
	decidirAnimacion(direction, isJumping)

	# Aplicar movimiento
	move_and_slide()

func decidirAnimacion(direction, isJumping):
	if isJumping:
		$AnimatedSprite2D.play("jumping")
	elif direction != 0:
		$AnimatedSprite2D.play("walking")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		$AnimatedSprite2D.play("idle")
