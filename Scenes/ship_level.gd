extends Node2D
@onready var ship:Node2D = self
var tempHealth:float = 100
var maxHealth:float = 100

var originalY:float = 0
var endY:float = 100

func _ready() -> void:
	originalY = ship.position.y
	endY = originalY+150
	
	maxHealth = tempHealth


func _process(delta: float) -> void:
	tempHealth -= 0.1*delta
	var healthProgress = 1-(tempHealth/maxHealth)
	
	ship.position.y = lerp(ship.position.y,endY,healthProgress)
