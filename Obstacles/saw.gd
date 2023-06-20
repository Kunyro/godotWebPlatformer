class_name Saw
extends Area2D

# Decalare animated_sprite variable assigned to the AnimatedSprite2D Node
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.play("spin")

func _on_body_entered(body):
	pass
