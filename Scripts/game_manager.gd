extends Node2D
var currentPlayer: Player

var shipHealth = 100
var defaultHealth = 100
var timer = 0

var currentScene:Node = null
var currentSceneName = "Ship"

var InteractablesNode:Node2D = null
var holeScene:PackedScene = preload("res://Scenes/interactable-Hole.tscn")
var timerUI:Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetGame()

func _process(delta: float) -> void:
	currentScene = get_tree().current_scene
	if currentScene == null: return
	if currentScene.name != "Main": return
	if InteractablesNode == null:
		InteractablesNode = currentScene.get_node("ShipNode").get_node("ShipMask").get_node("ShipLevel").get_node("Interactables")
	if timerUI == null:
		timerUI = currentScene.get_node("TimerUI").get_node("timerUI")
	
	timer += delta
	timerUI.get_node("TextLabel").text = richTextWavy(str(timer).pad_decimals(2))
	
	currentShakeLevel = lerp(currentShakeLevel,maxShakeLevel,timer/10)
	currentShakeRate = lerp(currentShakeRate,maxShakeRate,timer/10)
	
	# the game timer probably goes in here too
	#spawnHole()

	


signal playerReady(player)
func setCurrentPlayer(player):
	currentPlayer = player
	playerReady.emit(player)
	
func resetGame():
	timer = 0
	shipHealth = defaultHealth
	
func spawnHole():
	var holeClone = holeScene.instantiate()
	var randomPos = Vector2(0,0)
	holeClone.position = randomPos
	InteractablesNode.add_child(holeClone)
	
	
var maxShakeRate:float = 150.0
var maxShakeLevel:float = 35.0
var currentShakeRate:float = 0.0
var currentShakeLevel:float = 0.0

func richTextWavy(text:String):
	return "[shake rate="+str(currentShakeRate)+" level="+str(currentShakeLevel)+" connected=1]"+text+"[/shake]"
