extends CharacterBody2D

@export var speed = 100.0
@onready var animated_sprite = $AnimatedSprite2D2

func _ready():
	animated_sprite.play("walk_down")
	animated_sprite.pause()

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		
	velocity = direction * speed
	
	move_and_slide()
	
	if direction.length() > 0:
		play_walk_animation(direction)
	else:
		animated_sprite.pause()
	
func play_walk_animation(direction):
	animated_sprite.speed_scale = 1.0
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			# For right movement, flip the left animation
			animated_sprite.play("walk_left")
			animated_sprite.flip_h = true
		else:
			animated_sprite.play("walk_left")
			animated_sprite.flip_h = false
	else:
		if direction.y > 0:
			animated_sprite.play("walk_down")
			animated_sprite.flip_h = false
		else:
			animated_sprite.play("walk_up")
			animated_sprite.flip_h = false
