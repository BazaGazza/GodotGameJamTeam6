extends Node2D
var currentPlayer: Player

var shipHealth = 100
var defaultHealth = 100
var timer = 0

var currentScene:Node = null
var currentSceneName = "Ship"

var InteractablesNode:Node2D = null
var holeScene:PackedScene = preload("res://Scenes/interactable-Hole.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetGame()

func _process(delta: float) -> void:
	currentScene = get_tree().current_scene
	if currentScene == null: return
	if currentScene.name != "Main": return
	if InteractablesNode == null:
		InteractablesNode = currentScene.get_node("ShipNode").get_node("ShipMask").get_node("ShipLevel").get_node("Interactables")

	timer += delta
	# the game timer probably goes in here too
	spawnHole()

	


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
	
