extends Area2D
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("idle")

func _on_body_entered(body):
	# Expands player 1 explosion radius
	if body.is_in_group("player"):
		if body.explosion_radius <= body.max_explosion_radius:
			body.explosion_radius += 20
			body.explosion_boost_count += 1
			body.start_explosion_boost_timer()
		self.queue_free()
		
	# Expands player 2 explosion radius
	if body.is_in_group("player_2"):
		if body.explosion_radius <= body.max_explosion_radius:
			body.explosion_radius += 20
			body.explosion_boost_count += 1
			body.start_explosion_boost_timer()
		self.queue_free()
