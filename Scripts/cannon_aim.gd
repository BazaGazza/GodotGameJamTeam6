extends Node2D

@onready var Aimer:Node2D = self
@onready var Line:Line2D = $Line2D
@onready var Hitbox:Area2D = $Hitbox

var explosionSprite:Sprite2D = null 
var currentPlayer:Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.currentPlayer:
		currentPlayer = GameManager.currentPlayer
	else:
		GameManager.playerReady.connect(func(newPlayer):currentPlayer = newPlayer)
	
	explosionSprite = Hitbox.get_node("ExplosionSprite")
	Aimer.visible = false
	

var rotationDirection = 1
var rotSpeed = 50
var aiming = false


func _physics_process(delta: float) -> void:
	if not aiming: return
	
	var newRotation = Aimer.rotation_degrees + rotSpeed * rotationDirection * delta
	
	if newRotation >= 35:
		newRotation = 35
		rotationDirection = -1
	elif newRotation <= -35:
		newRotation = -35
		rotationDirection = 1
	Aimer.rotation_degrees = newRotation

func startAim():
	
	Aimer.rotation_degrees = randf_range(-35,35)
	
	var defaultOffset = currentPlayer.playerCamera.get_meta("DefaultOffset")
	Aimer.visible = true
	aiming = true
	currentPlayer.playerCamera.offset = Vector2(0,defaultOffset*2)
	
	while aiming:
		if Input.is_action_just_pressed("interact"):
			aiming = false
		await get_tree().process_frame
		
	explosionSprite.visible = true
	var hitAreas = Hitbox.get_overlapping_areas()
	for hurtbox in hitAreas:
		if hurtbox.owner is EnemyShip:
			var ship:EnemyShip = hurtbox.owner
			ship.destroy()

	
	await get_tree().create_timer(0.5,false).timeout
	explosionSprite.visible = false

	
	Aimer.visible = false
	currentPlayer.playerCamera.offset = Vector2(0,defaultOffset)
	return
	
