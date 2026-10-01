extends Node2D

@onready var ship:Node2D = self
var originalY
var endY

func _ready() -> void:
	originalY = ship.position.y
	endY = originalY+150

func _process(delta: float) -> void:
	
	var damage:int = 0
	damage = GameManager.spawnedHoles * 2
	
	GameManager.currentHealth -= damage*delta
	var progress = 1-(GameManager.currentHealth/GameManager.maxHealth)
	progress = clamp(progress,0,1)
	ship.position.y = lerp(originalY,endY,progress)
