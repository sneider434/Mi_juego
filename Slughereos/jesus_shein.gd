extends CharacterBody2D

var speed = 350
var jump_velocity = -530
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dashing = false
var dash_timer = 0.0
var dash_duration = 0.2
var dash_speed = 1000

var anim = null
var disparando = false
var disparo_timer = 0.0
var disparo_duracion = 1.0  # Duración del disparo en segundos

var recargando = false
var recarga_timer = 0.0
var recarga_duracion = 1.5

var danado = false
var dano_timer = 0.0
var dano_duracion = 0.6

var curando = false
var curar_timer = 0.0
var curar_duracion = 0.5  # duración de la animación curar (medio segundo)

var muriendo = false
var muerto = false

# Sistema de vida
var vida_maxima = 100
var vida_actual = vida_maxima

func _ready():
	anim = $AnimatedSprite2D

func _physics_process(delta):
	if muerto:
		return  # No mover ni procesar si ya está muerto

	var input_dir = Vector2.ZERO

	# Movimiento lateral
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1

	# Dash
	if Input.is_action_just_pressed("Dash") and not is_dashing and is_on_floor():
		is_dashing = true
		dash_timer = dash_duration
		if input_dir.x != 0:
			velocity.x = input_dir.x * dash_speed
		else:
			velocity.x = (anim.flip_h if anim.flip_h else 1) * dash_speed

	# Dash activo
	if is_dashing:
		dash_timer -= delta
		velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false

	if not is_dashing:
		velocity.x = input_dir.x * speed

		# Salto y gravedad
		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
		else:
			velocity.y += gravity * delta

	move_and_slide()

	# Disparo
	if Input.is_action_just_pressed("shoot") and not recargando and not muriendo:
		disparar()

	if disparando:
		disparo_timer -= delta
		if disparo_timer <= 0:
			disparando = false

	# Recarga (simulada con la tecla R)
	if Input.is_action_just_pressed("recargar") and not recargando and not disparando:
		recargar()

	if recargando:
		recarga_timer -= delta
		if recarga_timer <= 0:
			recargando = false

	# Daño (simulado con la tecla D)
	if Input.is_action_just_pressed("Dano") and not danado and not muriendo:
		recibir_dano(20)  # Daño de 20 puntos como ejemplo

	if danado:
		dano_timer -= delta
		if dano_timer <= 0:
			danado = false

	# Curar (simulado con la tecla C)
	if Input.is_action_just_pressed("Vida") and not muriendo and not muerto:
		curar(20)  # Cura 20 puntos

	if curando:
		curar_timer -= delta
		if curar_timer <= 0:
			curando = false

	# Muerte (automática si vida <= 0)
	if vida_actual <= 0 and not muriendo:
		morir()

	if muriendo:
		velocity = Vector2.ZERO

	# Animaciones
	actualizar_animacion()

func disparar():
	disparando = true
	disparo_timer = disparo_duracion
	anim.play("Dispara_movimiento")
	print("¡Disparo!")

func recargar():
	recargando = true
	recarga_timer = recarga_duracion
	anim.play("Recarga")
	print("Recargando...")

func recibir_dano(cantidad):
	if muriendo or muerto:
		return
	vida_actual -= cantidad
	print("Daño recibido:", cantidad, "Vida actual:", vida_actual)
	danado = true
	dano_timer = dano_duracion
	anim.play("Dano")

func curar(cantidad):
	if muriendo or muerto:
		return
	vida_actual += cantidad
	if vida_actual > vida_maxima:
		vida_actual = vida_maxima
	print("Curado:", cantidad, "Vida actual:", vida_actual)
	curando = true
	curar_timer = curar_duracion
	anim.play("Vida")  # Verifica que esta animación exista y el nombre sea correcto

func morir():
	muriendo = true
	muerto = true
	anim.play("Muerte")
	print("¡Has muerto!")

func actualizar_animacion():
	var nueva_animacion = ""

	if muriendo:
		nueva_animacion = "Muerte"
	elif danado:
		nueva_animacion = "Dano"
	elif recargando:
		nueva_animacion = "Recarga"
	elif curando:
		nueva_animacion = "Vida"
	elif is_dashing:
		nueva_animacion = "Dash"
	elif disparando:
		nueva_animacion = "Dispara_movimiento"
	elif not is_on_floor():
		nueva_animacion = "Saltar"
	elif velocity.x != 0:
		nueva_animacion = "Correr"
	else:
		nueva_animacion = "Estatico"

	if anim.animation != nueva_animacion:
		anim.play(nueva_animacion)

	anim.flip_h = velocity.x < 0
