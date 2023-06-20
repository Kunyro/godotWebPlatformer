class_name Player
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Declare can_double_jump variable to be used
var can_double_jump = false
# Declare if the player has reached the end
var reached_end = false
# Player position
@onready var spawn_pos = position
# Decalare animated_sprite variable assigned to the AnimatedSprite2D Node
@onready var animated_sprite = $AnimatedSprite2D
# Declare CoyoteTimer variable
@onready var coyote_timer = $CoyoteTimer
# Declare JumpBuffer variable
@onready var jump_buffer_timer = $JumpBufferTimer
# Declare EndTimer variable
@onready var end_timer = $EndTimer

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		# If the player is rising, play jump
		if velocity.y <= 0:
			animated_sprite.play("jump")
		# If you double jumped, fall with cool flip animation
		elif can_double_jump == false:
			animated_sprite.play("double_jump")
		# Else, he is falling so play fall
		else:
			animated_sprite.play("fall")

	else:
		# If the player is grounded and isnt moving, play idle
		if velocity.x == 0:
			animated_sprite.play("idle")
		# Else, he is moving on the ground so play run
		else:
			animated_sprite.play("run")

	# Handle Jumps.
	# Jump buffer setup, keep track of wther the player pressed jump
	var pressed_jump = false
		
	# If you are on the floor or if the coyote timer hasnt run out, jump
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		# If you jump from ground, then allow a double jump
		can_double_jump = true
		# Update pressed_jump
		pressed_jump = true
	# Elif you buffered jump in time
	elif !jump_buffer_timer.is_stopped() and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# If you jump from ground, then allow a double jump
		can_double_jump = true
		# Update pressed_jump
		pressed_jump = true

	# If you are in the air and can_double_jump = true then jump again and do animation
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_double_jump == true:
		velocity.y = JUMP_VELOCITY
		# Prevent infinite double jumps
		can_double_jump = false
		# Update pressed_jump
		pressed_jump = true
	
	# If you are rising form your jump and let go of button, halve your velocity
	# This allows for variable jump height
	if Input.is_action_just_released("ui_accept") and velocity.y <= 0:
		velocity.y /= 2
	
	# If you are holding your jump you will fall slower
	if Input.is_action_pressed("ui_accept") and velocity.y >= 0:
		velocity.y /= 1.5

	# Coyote timer setup, keep track of wether the player was on the floor or not
	var was_on_floor = is_on_floor()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	# If the caracter hasnt gotten hit then do the movement logic
	if direction:
		velocity.x = direction * SPEED
		# If the player is going left, flip him (since facing right is default)
		if velocity.x < 0:
			animated_sprite.flip_h = true
		# If the player is facing right again, reverse the flip
		elif velocity.x > 0:
			animated_sprite.flip_h = false
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
		
	# move_and_slide() refreshes the is_on_floor check
	# If the player was on the floor the previous frame but not this frame,
	# Start the timer
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
	
	# If you pressed jump at any time after, start jump buffer timer
	if !pressed_jump and Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer.start()
	
	# If you have been in the end zone for 5 seconds, go back to menu
	if end_timer.is_stopped() and reached_end:
		
		get_tree().change_scene_to_file("res://Menus/Menu.tscn")

# Handle checkpoints
func _on_check_point_body_entered(body):
	print("CHECKPOINT")
	spawn_pos = body.position
	
# When you get hit by saw, respawn at the last checkpoint
func _on_saw_body_entered(_body):
	animated_sprite.play("hit")
	position = spawn_pos

# When you reach the end area, if you stay for over 5 seconds the game ends
func _on_level_end_body_entered(_body):
	end_timer.start()
	print(end_timer.time_left)
	reached_end = true
