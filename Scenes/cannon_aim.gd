extends Node2D

@onready var Aimer:Node2D = self
@onready var Line:Line2D = $Line2D
@onready var Hitbox:Area2D = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var rotationDirection = 1
var rotSpeed = 50

func _physics_process(delta: float) -> void:
	var newRotation = Aimer.rotation_degrees + rotSpeed * rotationDirection * delta
	
	if newRotation >= 90:
		newRotation = 90
		rotationDirection = -1
	elif newRotation <= -90:
		newRotation = -90
		rotationDirection = 1
	Aimer.rotation_degrees = newRotation
