class_name Player
extends CharacterBody2D

@export var baseSpeed = 100
var movementSpeed
var doingMinigame:bool = false

@onready var playerCamera:Camera2D = $Camera2D
@onready var playerSprite = $AnimatedSprite2D


var EventChance



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GameManager.currentPlayer = self
	GameManager.setCurrentPlayer(self)
	playerCamera.set_meta("DefaultOffset",playerCamera.offset.y)
	movementSpeed = baseSpeed
	
	GameManager.startingSequence()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


var testing = true

	
func _physics_process(delta:float):
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		playerSprite.flip_h = true
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		playerSprite.flip_h = false
		velocity.x -= 1
		
	if GameManager.currentSceneName == "Ship":
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1

	
	if velocity.length() > 0 and movementSpeed > 0:
		velocity = velocity.normalized()*movementSpeed
		playerSprite.play("walk")
	else:
		playerSprite.animation = "idle"

	move_and_slide()
