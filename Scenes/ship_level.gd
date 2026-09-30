extends Node2D

@onready var ship:Node2D = self
@onready var tempHealth = GameManager.shipHealth
var maxHealth = 100

var originalY
var endY

func _ready() -> void:
	maxHealth = tempHealth
	originalY = ship.position.y
	endY = originalY+150

func _process(delta: float) -> void:
	tempHealth -= 10*delta
	
	var progress = 1-(tempHealth/maxHealth)
	progress = clamp(progress,0,1)
	ship.position.y = lerp(originalY,endY,progress)
