extends CharacterBody2D

var anim: AnimatedSprite2D
var jugador_en_rango: bool = false
var jugador: Node = null

var speed: float = 150.0
var ataque_distancia: float = 30.0
var puede_atacar: bool = true
var tiempo_entre_ataques: float = 1.5
var timer_ataque: float = 0.0


func _on_Disparar_heroe_body_entered(body: Node) -> void:
	if body.name == "heroe":  # Ajusta el nombre exacto si es otro
		jugador_en_rango = true
		jugador = body
		print("Jugador detectado en rango!")
		anim.play("attack")


func _on_Disparar_heroe_body_exited(body: Node) -> void:
	if body.name == "heroe":
		jugador_en_rango = false
		jugador = null
		print("Jugador salió del rango")
		anim.play("idle")

func _ready() -> void:
	anim = $AnimatedSprite2D
	$Disparar_heroe.body_entered.connect(Callable(self, "_on_Disparar_heroe_body_entered"))
	$Disparar_heroe.body_exited.connect(Callable(self, "_on_Disparar_heroe_body_exited"))

func _process(delta: float) -> void:
	if jugador_en_rango and jugador != null:
		var direccion = (jugador.global_position - global_position).normalized()
		var distancia = global_position.distance_to(jugador.global_position)

		if distancia > ataque_distancia:
			# Mover hacia el jugador
			velocity = direccion * speed
			move_and_slide()
			anim.play("flyng")  # animación para moverse
		else:
			# Atacar si está en rango
			velocity = Vector2.ZERO
			if puede_atacar:
				anim.play("attack")
				puede_atacar = false
				timer_ataque = tiempo_entre_ataques
				print("¡Atacando al jugador!")
				# Aquí podrías llamar a función que haga daño al jugador
			else:
				anim.play("idle")
	else:
		velocity = Vector2.ZERO
		anim.play("idle")

	# Cooldown para el siguiente ataque
	if not puede_atacar:
		timer_ataque -= delta
		if timer_ataque <= 0:
			puede_atacar = true


func _on_disparar_heroe_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_disparar_heroe_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
