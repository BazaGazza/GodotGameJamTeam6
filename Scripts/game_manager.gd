extends Node2D
var currentPlayer: Player

var currentHealth = 100
const maxHealth = 100
var timer = 0

var currentScene:Node = null
var currentSceneName = "Ship"
var currentMinigame:String = ""

var spawnedHoles:int = 0
var InteractablesNode:Node2D = null
var holeArea:Area2D = null
var holeShape = null
var holeScene:PackedScene = preload("res://Scenes/interactable-Hole.tscn")
var timerUI:Control = null

const shakeMaxLength = 10
var maxShakeRate:float = 150.0
var maxShakeLevel:float = 35.0
var currentShakeRate:float = 0.0
var currentShakeLevel:float = 0.0
var baseShakeLevel = 0.0
var baseShakeRate = 0.0


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
	if holeArea == null:
		holeArea = currentScene.get_node("ShipNode").get_node("ShipMask").get_node("ShipLevel").get_node("HoleArea")
		holeShape = holeArea.get_node("CollisionShape2D")
	
	timer += delta
	timerUI.get_node("TextLabel").text = richTextWavy(str(timer).pad_decimals(2))
	
	var progress = clamp(timer/shakeMaxLength,0,1)
	currentShakeLevel = lerp(baseShakeLevel,maxShakeLevel,progress)
	currentShakeRate = lerp(baseShakeRate,maxShakeRate,progress)
	
	# the game timer probably goes in here too
	var timerInt = floor(timer)
	if timerInt > 0 and spawnedHoles < timerInt:
		spawnedHoles += 1
		spawnHole()

	


signal playerReady(player)
func setCurrentPlayer(player):
	currentPlayer = player
	playerReady.emit(player)
	
func resetGame():
	timer = 0
	currentHealth = maxHealth
	currentMinigame = ""
	spawnedHoles = 0
	
	if InteractablesNode == null: return
	for child in InteractablesNode.get_children():
		if child.get_meta("Clone"):
			child.queue_free()
	
func spawnHole():
	var holeClone = holeScene.instantiate()

	var spawnShape:RectangleShape2D = holeShape.shape as RectangleShape2D
	var spawnSize:Vector2 = spawnShape.size
	
	var ranX = randf_range(-spawnSize.x/2,spawnSize.x/2)
	var ranY = randf_range(-spawnSize.y/2,spawnSize.y/2)
	var randomLocalPos:Vector2 = Vector2(ranX,ranY)
	var randomGlobalPos = holeShape.to_global(randomLocalPos)
	
	holeClone.position = InteractablesNode.to_local(randomGlobalPos)
	var holeIcon:TextureRect = holeClone.get_node("HoleIcon")
	
	var randomScale = randf_range(0.9, 1.4)*holeIcon.scale
	holeIcon.scale = randomScale
	holeIcon.rotation = randf_range(-360,360)
	holeClone.set_meta("Clone",true)
	
	InteractablesNode.add_child(holeClone)
	
func richTextWavy(text:String):
	return "[shake rate="+str(currentShakeRate)+" level="+str(currentShakeLevel)+" connected=1]"+text+"[/shake]"
